import { TransactionsService } from './transactions.service';
import { ValidateTransactionDto, TransactionHistoryDto } from './dto';
export declare class TransactionsController {
    private readonly transactionsService;
    constructor(transactionsService: TransactionsService);
    validateAndProcessTransaction(userId: string, dto: ValidateTransactionDto): Promise<{
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
}
