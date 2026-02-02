"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var TransactionsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.TransactionsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../prisma/prisma.service");
const wallets_service_1 = require("../wallets/wallets.service");
const crypto = __importStar(require("crypto"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
let TransactionsService = TransactionsService_1 = class TransactionsService {
    prisma;
    walletsService;
    configService;
    logger = new common_1.Logger(TransactionsService_1.name);
    tokenValidityMs;
    sessionValidityMs;
    encryptionKey;
    signingSecret;
    sessions = new Map();
    translations = {
        en: {},
        ar: {},
    };
    constructor(prisma, walletsService, configService) {
        this.prisma = prisma;
        this.walletsService = walletsService;
        this.configService = configService;
        this.tokenValidityMs = this.configService.get('nfc.tokenValidityMs', 120000);
        this.sessionValidityMs = this.configService.get('nfc.sessionValidityMs', 300000);
        this.encryptionKey = this.configService.get('encryption.key', '');
        this.signingSecret = this.configService.get('nfc.signingSecret', '');
        this.loadTranslations();
        const nodeEnv = this.configService.get('nodeEnv');
        if (nodeEnv !== 'development') {
            if (!process.env.ENCRYPTION_KEY) {
                this.logger.warn('ENCRYPTION_KEY not set - using default (insecure for production)');
            }
            if (!process.env.NFC_SIGNING_SECRET) {
                this.logger.warn('NFC_SIGNING_SECRET not set - using default (insecure for production)');
            }
        }
        setInterval(() => this.cleanupExpiredSessions(), 60000);
    }
    loadTranslations() {
        try {
            const enPath = path.join(__dirname, '..', 'common', 'i18n', 'en.json');
            const arPath = path.join(__dirname, '..', 'common', 'i18n', 'ar.json');
            if (fs.existsSync(enPath)) {
                this.translations.en = JSON.parse(fs.readFileSync(enPath, 'utf-8'));
            }
            if (fs.existsSync(arPath)) {
                this.translations.ar = JSON.parse(fs.readFileSync(arPath, 'utf-8'));
            }
        }
        catch (e) {
            this.logger.warn('Failed to load i18n translations', e);
        }
    }
    t(key, lang = 'en') {
        return this.translations[lang]?.[key] || this.translations.en?.[key] || key;
    }
    async createTransactionSession(receiverUserId, dto, lang = 'en') {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId: receiverUserId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException(this.t('wallet_not_found', lang));
        }
        const sessionId = `SES_${crypto.randomBytes(16).toString('hex')}`;
        const session = {
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
    async getSessionStatus(sessionId, lang = 'en') {
        const session = this.sessions.get(sessionId);
        if (!session) {
            throw new common_1.NotFoundException(this.t('session_not_found', lang));
        }
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
    updateSessionStatus(sessionId, status) {
        const session = this.sessions.get(sessionId);
        if (session) {
            session.status = status;
            this.sessions.set(sessionId, session);
        }
    }
    cleanupExpiredSessions() {
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
    async validateAndProcessTransaction(merchantUserId, dto) {
        if (dto.idempotencyKey) {
            const existingTransaction = await this.prisma.transaction.findUnique({
                where: { idempotencyKey: dto.idempotencyKey },
            });
            if (existingTransaction) {
                return existingTransaction;
            }
        }
        const decodedToken = this.decodeNfcToken(dto.encryptedToken);
        if (!decodedToken) {
            throw new common_1.BadRequestException('Invalid payment token');
        }
        const now = Date.now();
        if (now - decodedToken.timestamp > this.tokenValidityMs) {
            throw new common_1.BadRequestException('Payment token has expired');
        }
        if (decodedToken.timestamp > now) {
            throw new common_1.BadRequestException('Payment token has invalid timestamp');
        }
        const existingNonce = await this.prisma.usedNonce.findUnique({
            where: { nonce: decodedToken.nonce },
        });
        if (existingNonce) {
            throw new common_1.ConflictException('Transaction already processed (duplicate nonce)');
        }
        const merchantWallet = await this.prisma.wallet.findUnique({
            where: { userId: merchantUserId },
        });
        if (!merchantWallet) {
            throw new common_1.NotFoundException('Merchant wallet not found');
        }
        if (dto.merchantWalletId && dto.merchantWalletId !== merchantWallet.id) {
            throw new common_1.BadRequestException('Merchant wallet mismatch');
        }
        const payerWallet = await this.prisma.wallet.findUnique({
            where: { id: decodedToken.walletId },
        });
        if (!payerWallet) {
            throw new common_1.NotFoundException('Payer wallet not found');
        }
        if (payerWallet.status !== 'ACTIVE') {
            throw new common_1.BadRequestException('Payer wallet is suspended');
        }
        if (dto.amount !== decodedToken.amount) {
            throw new common_1.BadRequestException('Amount mismatch');
        }
        const payerBalance = Number(payerWallet.balance);
        if (payerBalance < dto.amount) {
            throw new common_1.BadRequestException('Insufficient balance');
        }
        const transaction = await this.prisma.$transaction(async (tx) => {
            await tx.usedNonce.create({
                data: {
                    nonce: decodedToken.nonce,
                    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
                },
            });
            await tx.wallet.update({
                where: { id: payerWallet.id },
                data: {
                    balance: {
                        decrement: dto.amount,
                    },
                },
            });
            await tx.wallet.update({
                where: { id: merchantWallet.id },
                data: {
                    balance: {
                        increment: dto.amount,
                    },
                },
            });
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
    async getTransactionHistory(userId, dto) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
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
    async getTransactionById(userId, transactionId) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
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
            throw new common_1.NotFoundException('Transaction not found');
        }
        if (transaction.payerWalletId !== wallet.id &&
            transaction.merchantWalletId !== wallet.id) {
            throw new common_1.NotFoundException('Transaction not found');
        }
        return {
            ...transaction,
            direction: transaction.payerWalletId === wallet.id ? 'outgoing' : 'incoming',
        };
    }
    decodeNfcToken(encryptedToken) {
        try {
            let tokenData;
            if (this.encryptionKey && this.encryptionKey.length >= 32) {
                tokenData = this.decryptToken(encryptedToken);
            }
            else {
                tokenData = Buffer.from(encryptedToken, 'base64').toString('utf-8');
            }
            const token = JSON.parse(tokenData);
            if (!token.userId ||
                !token.walletId ||
                typeof token.amount !== 'number' ||
                !token.timestamp ||
                !token.nonce ||
                !token.deviceId ||
                !token.signature) {
                this.logger.warn('Token missing required fields');
                return null;
            }
            if (!this.verifyTokenSignature(token)) {
                this.logger.warn('Token signature verification failed');
                return null;
            }
            return token;
        }
        catch (error) {
            this.logger.error('Failed to decode NFC token', error);
            return null;
        }
    }
    decryptToken(encryptedToken) {
        const combined = Buffer.from(encryptedToken, 'base64');
        const iv = combined.subarray(0, 12);
        const authTag = combined.subarray(combined.length - 16);
        const encryptedData = combined.subarray(12, combined.length - 16);
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
    verifyTokenSignature(token) {
        const { userId, walletId, amount, timestamp, signature } = token;
        const data = `${userId}|${walletId}|${amount}|${timestamp}`;
        const expectedSignature = crypto
            .createHmac('sha256', this.signingSecret)
            .update(data)
            .digest('base64');
        try {
            return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature));
        }
        catch {
            return false;
        }
    }
    async cleanupExpiredNonces() {
        const result = await this.prisma.usedNonce.deleteMany({
            where: {
                expiresAt: { lt: new Date() },
            },
        });
        this.logger.debug(`Cleaned up ${result.count} expired nonces`);
    }
};
exports.TransactionsService = TransactionsService;
exports.TransactionsService = TransactionsService = TransactionsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        wallets_service_1.WalletsService,
        config_1.ConfigService])
], TransactionsService);
//# sourceMappingURL=transactions.service.js.map