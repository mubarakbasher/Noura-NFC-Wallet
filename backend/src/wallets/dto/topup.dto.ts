import { IsNumber, IsPositive, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class TopUpDto {
    @IsNumber()
    @IsPositive({ message: 'Amount must be positive' })
    @Type(() => Number)
    amount: number;

    @IsString()
    @IsOptional()
    reference?: string;
}
