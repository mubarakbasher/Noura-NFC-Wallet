import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { WalletsService } from '../wallets/wallets.service';
import { ValidateTransactionDto, TransactionHistoryDto, CreateTransactionSessionDto } from './dto';
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
export declare class TransactionsService {
    private readonly prisma;
    private readonly walletsService;
    private readonly configService;
    private readonly logger;
    private readonly tokenValidityMs;
    private readonly sessionValidityMs;
    private readonly encryptionKey;
    private readonly signingSecret;
    private readonly sessions;
    private readonly translations;
    constructor(prisma: PrismaService, walletsService: WalletsService, configService: ConfigService);
    private loadTranslations;
    private t;
    createTransactionSession(receiverUserId: string, dto: CreateTransactionSessionDto, lang?: string): Promise<{
        sessionId: string;
        amount: number;
        status: "COMPLETED" | "PENDING" | "WAITING" | "PROCESSING" | "FAILED" | "EXPIRED";
        expiresAt: Date;
        receiverWalletId: string;
        createdAt: Date;
        message: string;
    }>;
    getSessionStatus(sessionId: string, lang?: string): Promise<{
        sessionId: string;
        amount: number;
        status: "COMPLETED" | "PENDING" | "WAITING" | "PROCESSING" | "FAILED" | "EXPIRED";
        expiresAt: Date;
        createdAt: Date;
    }>;
    updateSessionStatus(sessionId: string, status: TransactionSession['status']): void;
    private cleanupExpiredSessions;
    validateAndProcessTransaction(merchantUserId: string, dto: ValidateTransactionDto): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        currency: string;
        amount: number;
        type: string;
        nonce: string | null;
        idempotencyKey: string | null;
        metadata: string | null;
        completedAt: Date | null;
        payerWalletId: string;
        merchantWalletId: string;
    }>;
    getTransactionHistory(userId: string, dto: TransactionHistoryDto): Promise<{
        transactions: {
            direction: string;
            payerWallet: {
                user: {
                    email: string;
                    fullName: string;
                };
            } & {
                id: string;
                status: string;
                createdAt: Date;
                updatedAt: Date;
                userId: string;
                balance: number;
                currency: string;
            };
            merchantWallet: {
                user: {
                    email: string;
                    fullName: string;
                };
            } & {
                id: string;
                status: string;
                createdAt: Date;
                updatedAt: Date;
                userId: string;
                balance: number;
                currency: string;
            };
            id: string;
            status: string;
            createdAt: Date;
            currency: string;
            amount: number;
            type: string;
            nonce: string | null;
            idempotencyKey: string | null;
            metadata: string | null;
            completedAt: Date | null;
            payerWalletId: string;
            merchantWalletId: string;
        }[];
        pagination: {
            page: number;
            pageSize: number;
            total: number;
            totalPages: number;
            hasMore: boolean;
        };
    }>;
    getTransactionById(userId: string, transactionId: string): Promise<{
        direction: string;
        payerWallet: {
            user: {
                email: string;
                fullName: string;
            };
        } & {
            id: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            balance: number;
            currency: string;
        };
        merchantWallet: {
            user: {
                email: string;
                fullName: string;
            };
        } & {
            id: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            balance: number;
            currency: string;
        };
        id: string;
        status: string;
        createdAt: Date;
        currency: string;
        amount: number;
        type: string;
        nonce: string | null;
        idempotencyKey: string | null;
        metadata: string | null;
        completedAt: Date | null;
        payerWalletId: string;
        merchantWalletId: string;
    }>;
    private decodeNfcToken;
    private decryptToken;
    private verifyTokenSignature;
    cleanupExpiredNonces(): Promise<void>;
}
export {};
