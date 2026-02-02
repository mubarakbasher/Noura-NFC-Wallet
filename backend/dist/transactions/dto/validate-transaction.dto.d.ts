export declare class ValidateTransactionDto {
    encryptedToken: string;
    amount: number;
    merchantWalletId?: string;
    idempotencyKey?: string;
    metadata?: Record<string, any>;
}
