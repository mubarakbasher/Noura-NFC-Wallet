import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';

export class UpdateProfileDto {
    @IsString()
    @IsOptional()
    fullName?: string;

    @IsString()
    @IsOptional()
    phone?: string;

    @IsString()
    @IsOptional()
    language?: string;
}

export class UpdatePinDto {
    @IsString()
    @MinLength(4)
    @MaxLength(6)
    pin: string;

    @IsString()
    @IsOptional()
    currentPin?: string;
}
