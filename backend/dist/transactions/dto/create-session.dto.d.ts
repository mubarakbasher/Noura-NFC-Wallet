export declare class CreateTransactionSessionDto {
    amount: number;
    description?: string;
    merchantReference?: string;
}
export declare class TransactionSessionResponse {
    sessionId: string;
    amount: number;
    status: 'PENDING' | 'WAITING' | 'PROCESSING' | 'COMPLETED' | 'FAILED' | 'EXPIRED';
    expiresAt: Date;
    receiverWalletId: string;
    createdAt: Date;
}
