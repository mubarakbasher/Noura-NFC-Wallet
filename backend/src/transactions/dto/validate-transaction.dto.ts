import { IsNumber, IsPositive, IsString, IsNotEmpty, IsOptional, IsObject } from 'class-validator';
import { Type } from 'class-transformer';

export class ValidateTransactionDto {
    @IsString()
    @IsNotEmpty()
    encryptedToken: string;

    @IsNumber()
    @IsPositive({ message: 'Amount must be positive' })
    @Type(() => Number)
    amount: number;

    @IsString()
    @IsOptional()
    merchantWalletId?: string;

    @IsString()
    @IsOptional()
    idempotencyKey?: string;

    @IsObject()
    @IsOptional()
    metadata?: Record<string, any>;
}
