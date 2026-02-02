import { IsNumber, IsOptional, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class TransactionHistoryDto {
    @IsNumber()
    @IsOptional()
    @Min(1)
    @Type(() => Number)
    page?: number = 1;

    @IsNumber()
    @IsOptional()
    @Min(1)
    @Max(100)
    @Type(() => Number)
    pageSize?: number = 20;
}
