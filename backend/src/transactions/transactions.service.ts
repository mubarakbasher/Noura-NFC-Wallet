import {
    Injectable,
    NotFoundException,
    BadRequestException,
    ConflictException,
    Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { WalletsService } from '../wallets/wallets.service';
import { ValidateTransactionDto, TransactionHistoryDto, CreateTransactionSessionDto } from './dto';
import * as crypto from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

interface DecodedToken {
    userId: string;
    walletId: string;
    amount: number;
    timestamp: number;
    nonce: string;
    deviceId: string;
    signature: string;
}

interface TransactionSession {
    id: string;
    receiverWalletId: string;
    receiverUserId: string;
    amount: number;
    status: 'PENDING' | 'WAITING' | 'PROCESSING' | 'COMPLETED' | 'FAILED' | 'EXPIRED';
    createdAt: Date;
    expiresAt: Date;
    description?: string;
    merchantReference?: string;
}

@Injectable()
export class TransactionsService {
    private readonly logger = new Logger(TransactionsService.name);
    private readonly tokenValidityMs: number;
    private readonly sessionValidityMs: number;
    private readonly encryptionKey: string;
    private readonly signingSecret: string;
    
    // In-memory session store (for production, use Redis)
    private readonly sessions: Map<string, TransactionSession> = new Map();
    
    // i18n translations
    private readonly translations: Record<string, Record<string, string>> = {
        en: {},
        ar: {},
    };

    constructor(
        private readonly prisma: PrismaService,
        private readonly walletsService: WalletsService,
        private readonly configService: ConfigService,
    ) {
        this.tokenValidityMs = this.configService.get<number>('nfc.tokenValidityMs', 120000);
        this.sessionValidityMs = this.configService.get<number>('nfc.sessionValidityMs', 300000); // 5 minutes
        this.encryptionKey = this.configService.get<string>('encryption.key', '');
        this.signingSecret = this.configService.get<string>('nfc.signingSecret', '');
        
        // Load i18n translations
        this.loadTranslations();
        
        // Warn if using default secrets in non-development
        const nodeEnv = this.configService.get<string>('nodeEnv');
        if (nodeEnv !== 'development') {
            if (!process.env.ENCRYPTION_KEY) {
                this.logger.warn('ENCRYPTION_KEY not set - using default (insecure for production)');
            }
            if (!process.env.NFC_SIGNING_SECRET) {
                this.logger.warn('NFC_SIGNING_SECRET not set - using default (insecure for production)');
            }
        }
        
        // Cleanup expired sessions periodically
        setInterval(() => this.cleanupExpiredSessions(), 60000);
    }
    
    /**
     * Load i18n translations from JSON files
     */
    private loadTranslations() {
        try {
            const enPath = path.join(__dirname, '..', 'common', 'i18n', 'en.json');
            const arPath = path.join(__dirname, '..', 'common', 'i18n', 'ar.json');
            
            if (fs.existsSync(enPath)) {
                this.translations.en = JSON.parse(fs.readFileSync(enPath, 'utf-8'));
            }
            if (fs.existsSync(arPath)) {
                this.translations.ar = JSON.parse(fs.readFileSync(arPath, 'utf-8'));
            }
        } catch (e) {
            this.logger.warn('Failed to load i18n translations', e);
        }
    }
    
    /**
     * Get translated message
     */
    private t(key: string, lang: string = 'en'): string {
        return this.translations[lang]?.[key] || this.translations.en?.[key] || key;
    }
    
    /**
     * Create a new transaction session (for receiver)
     * This initializes the payment request that payer will fulfill
     */
    async createTransactionSession(
        receiverUserId: string,
        dto: CreateTransactionSessionDto,
        lang: string = 'en',
    ) {
        // Get receiver's wallet
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId: receiverUserId },
        });
        
        if (!wallet) {
            throw new NotFoundException(this.t('wallet_not_found', lang));
        }
        
        // Generate unique session ID
        const sessionId = `SES_${crypto.randomBytes(16).toString('hex')}`;
        
        const session: TransactionSession = {
            id: sessionId,
            receiverWalletId: wallet.id,
            receiverUserId,
            amount: dto.amount,
            status: 'PENDING',
            createdAt: new Date(),
            expiresAt: new Date(Date.now() + this.sessionValidityMs),
            description: dto.description,
            merchantReference: dto.merchantReference,
        };
        
        // Store session
        this.sessions.set(sessionId, session);
        
        this.logger.log(`Transaction session created: ${sessionId} for amount ${dto.amount}`);
        
        return {
            sessionId: session.id,
            amount: session.amount,
            status: session.status,
            expiresAt: session.expiresAt,
            receiverWalletId: session.receiverWalletId,
            createdAt: session.createdAt,
            message: this.t('session_created', lang),
        };
    }
    
    /**
     * Get transaction session status
     */
    async getSessionStatus(sessionId: string, lang: string = 'en') {
        const session = this.sessions.get(sessionId);
        
        if (!session) {
            throw new NotFoundException(this.t('session_not_found', lang));
        }
        
        // Check if expired
        if (new Date() > session.expiresAt) {
            session.status = 'EXPIRED';
        }
        
        return {
            sessionId: session.id,
            amount: session.amount,
            status: session.status,
            expiresAt: session.expiresAt,
            createdAt: session.createdAt,
        };
    }
    
    /**
     * Update session status (for real-time updates)
     */
    updateSessionStatus(sessionId: string, status: TransactionSession['status']) {
        const session = this.sessions.get(sessionId);
        if (session) {
            session.status = status;
            this.sessions.set(sessionId, session);
        }
    }
    
    /**
     * Cleanup expired sessions
     */
    private cleanupExpiredSessions() {
        const now = new Date();
        let cleaned = 0;
        
        for (const [id, session] of this.sessions.entries()) {
            if (now > session.expiresAt) {
                this.sessions.delete(id);
                cleaned++;
            }
        }
        
        if (cleaned > 0) {
            this.logger.debug(`Cleaned up ${cleaned} expired sessions`);
        }
    }

    async validateAndProcessTransaction(
        merchantUserId: string,
        dto: ValidateTransactionDto,
    ) {
        // Check for idempotency key to prevent duplicate processing
        if (dto.idempotencyKey) {
            const existingTransaction = await this.prisma.transaction.findUnique({
                where: { idempotencyKey: dto.idempotencyKey },
            });

            if (existingTransaction) {
                // Return existing transaction (idempotent response)
                return existingTransaction;
            }
        }

        // Decode and validate the NFC token
        const decodedToken = this.decodeNfcToken(dto.encryptedToken);

        if (!decodedToken) {
            throw new BadRequestException('Invalid payment token');
        }

        // Validate token timestamp (not expired)
        const now = Date.now();
        if (now - decodedToken.timestamp > this.tokenValidityMs) {
            throw new BadRequestException('Payment token has expired');
        }

        if (decodedToken.timestamp > now) {
            throw new BadRequestException('Payment token has invalid timestamp');
        }

        // Check for nonce reuse (double-spend prevention)
        const existingNonce = await this.prisma.usedNonce.findUnique({
            where: { nonce: decodedToken.nonce },
        });

        if (existingNonce) {
            throw new ConflictException('Transaction already processed (duplicate nonce)');
        }

        // Get merchant wallet
        const merchantWallet = await this.prisma.wallet.findUnique({
            where: { userId: merchantUserId },
        });

        if (!merchantWallet) {
            throw new NotFoundException('Merchant wallet not found');
        }

        if (dto.merchantWalletId && dto.merchantWalletId !== merchantWallet.id) {
            throw new BadRequestException('Merchant wallet mismatch');
        }

        // Validate payer wallet
        const payerWallet = await this.prisma.wallet.findUnique({
            where: { id: decodedToken.walletId },
        });

        if (!payerWallet) {
            throw new NotFoundException('Payer wallet not found');
        }

        if (payerWallet.status !== 'ACTIVE') {
            throw new BadRequestException('Payer wallet is suspended');
        }

        // Validate amount
        if (dto.amount !== decodedToken.amount) {
            throw new BadRequestException('Amount mismatch');
        }

        // Check sufficient balance
        const payerBalance = Number(payerWallet.balance);
        if (payerBalance < dto.amount) {
            throw new BadRequestException('Insufficient balance');
        }

        // Process transaction atomically
        const transaction = await this.prisma.$transaction(async (tx) => {
            // Store the nonce to prevent replay attacks
            await tx.usedNonce.create({
                data: {
                    nonce: decodedToken.nonce,
                    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // Expire after 24 hours
                },
            });

            // Debit payer wallet
            await tx.wallet.update({
                where: { id: payerWallet.id },
                data: {
                    balance: {
                        decrement: dto.amount,
                    },
                },
            });

            // Credit merchant wallet
            await tx.wallet.update({
                where: { id: merchantWallet.id },
                data: {
                    balance: {
                        increment: dto.amount,
                    },
                },
            });

            // Create transaction record
            return tx.transaction.create({
                data: {
                    payerWalletId: payerWallet.id,
                    merchantWalletId: merchantWallet.id,
                    amount: dto.amount,
                    currency: payerWallet.currency,
                    type: 'NFC_PAYMENT',
                    status: 'COMPLETED',
                    nonce: decodedToken.nonce,
                    idempotencyKey: dto.idempotencyKey,
                    completedAt: new Date(),
                    metadata: JSON.stringify({
                        ...dto.metadata,
                        payerDeviceId: decodedToken.deviceId,
                    }),
                },
            });
        });

        return transaction;
    }

    async getTransactionHistory(userId: string, dto: TransactionHistoryDto) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        const page = dto.page || 1;
        const pageSize = dto.pageSize || 20;
        const skip = (page - 1) * pageSize;

        const [transactions, total] = await Promise.all([
            this.prisma.transaction.findMany({
                where: {
                    OR: [
                        { payerWalletId: wallet.id },
                        { merchantWalletId: wallet.id },
                    ],
                },
                orderBy: { createdAt: 'desc' },
                skip,
                take: pageSize,
                include: {
                    payerWallet: {
                        include: { user: { select: { fullName: true, email: true } } },
                    },
                    merchantWallet: {
                        include: { user: { select: { fullName: true, email: true } } },
                    },
                },
            }),
            this.prisma.transaction.count({
                where: {
                    OR: [
                        { payerWalletId: wallet.id },
                        { merchantWalletId: wallet.id },
                    ],
                },
            }),
        ]);

        // Add direction flag for each transaction
        const transactionsWithDirection = transactions.map((tx) => ({
            ...tx,
            direction: tx.payerWalletId === wallet.id ? 'outgoing' : 'incoming',
        }));

        return {
            transactions: transactionsWithDirection,
            pagination: {
                page,
                pageSize,
                total,
                totalPages: Math.ceil(total / pageSize),
                hasMore: skip + transactions.length < total,
            },
        };
    }

    async getTransactionById(userId: string, transactionId: string) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        const transaction = await this.prisma.transaction.findUnique({
            where: { id: transactionId },
            include: {
                payerWallet: {
                    include: { user: { select: { fullName: true, email: true } } },
                },
                merchantWallet: {
                    include: { user: { select: { fullName: true, email: true } } },
                },
            },
        });

        if (!transaction) {
            throw new NotFoundException('Transaction not found');
        }

        // Ensure user has access to this transaction
        if (
            transaction.payerWalletId !== wallet.id &&
            transaction.merchantWalletId !== wallet.id
        ) {
            throw new NotFoundException('Transaction not found');
        }

        return {
            ...transaction,
            direction: transaction.payerWalletId === wallet.id ? 'outgoing' : 'incoming',
        };
    }

    /**
     * Decode and validate NFC token
     * Supports both encrypted tokens (production) and base64-encoded JSON (development)
     */
    private decodeNfcToken(encryptedToken: string): DecodedToken | null {
        try {
            let tokenData: string;
            
            // Try to decrypt if encryption key is available
            if (this.encryptionKey && this.encryptionKey.length >= 32) {
                tokenData = this.decryptToken(encryptedToken);
            } else {
                // Fallback for development: base64-encoded JSON
                tokenData = Buffer.from(encryptedToken, 'base64').toString('utf-8');
            }

            const token = JSON.parse(tokenData);

            // Validate required fields
            if (
                !token.userId ||
                !token.walletId ||
                typeof token.amount !== 'number' ||
                !token.timestamp ||
                !token.nonce ||
                !token.deviceId ||
                !token.signature
            ) {
                this.logger.warn('Token missing required fields');
                return null;
            }

            // Verify signature
            if (!this.verifyTokenSignature(token)) {
                this.logger.warn('Token signature verification failed');
                return null;
            }

            return token as DecodedToken;
        } catch (error) {
            this.logger.error('Failed to decode NFC token', error);
            return null;
        }
    }

    /**
     * Decrypt AES-256-GCM encrypted token
     * Format: Base64(IV + EncryptedData + AuthTag)
     */
    private decryptToken(encryptedToken: string): string {
        const combined = Buffer.from(encryptedToken, 'base64');
        
        // AES-GCM uses 12-byte IV
        const iv = combined.subarray(0, 12);
        // Auth tag is last 16 bytes
        const authTag = combined.subarray(combined.length - 16);
        // Encrypted data is between IV and auth tag
        const encryptedData = combined.subarray(12, combined.length - 16);

        // Derive 32-byte key from encryption key
        const key = crypto
            .createHash('sha256')
            .update(this.encryptionKey)
            .digest();

        const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
        decipher.setAuthTag(authTag);

        const decrypted = Buffer.concat([
            decipher.update(encryptedData),
            decipher.final(),
        ]);

        return decrypted.toString('utf-8');
    }

    /**
     * Verify HMAC-SHA256 signature of token data
     */
    private verifyTokenSignature(token: DecodedToken): boolean {
        const { userId, walletId, amount, timestamp, signature } = token;
        
        // Reconstruct the data that was signed
        const data = `${userId}|${walletId}|${amount}|${timestamp}`;
        
        // Calculate expected signature using HMAC-SHA256
        const expectedSignature = crypto
            .createHmac('sha256', this.signingSecret)
            .update(data)
            .digest('base64');

        // Use timing-safe comparison to prevent timing attacks
        try {
            return crypto.timingSafeEqual(
                Buffer.from(signature),
                Buffer.from(expectedSignature),
            );
        } catch {
            // If buffers are different lengths, they're not equal
            return false;
        }
    }

    /**
     * Utility method to clean up expired nonces
     */
    async cleanupExpiredNonces() {
        const result = await this.prisma.usedNonce.deleteMany({
            where: {
                expiresAt: { lt: new Date() },
            },
        });
        this.logger.debug(`Cleaned up ${result.count} expired nonces`);
    }
}
