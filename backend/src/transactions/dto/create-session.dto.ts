import { IsNumber, IsString, IsOptional, Min, Max } from 'class-validator';

export class CreateTransactionSessionDto {
  @IsNumber()
  @Min(0.01)
  @Max(1000000)
  amount: number;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  merchantReference?: string;
}

export class TransactionSessionResponse {
  sessionId: string;
  amount: number;
  status: 'PENDING' | 'WAITING' | 'PROCESSING' | 'COMPLETED' | 'FAILED' | 'EXPIRED';
  expiresAt: Date;
  receiverWalletId: string;
  createdAt: Date;
}
