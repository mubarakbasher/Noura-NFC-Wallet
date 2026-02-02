import { IsString, IsNotEmpty, IsEnum, IsOptional } from 'class-validator';

export enum DeviceType {
    CARD = 'CARD',
    WRISTBAND = 'WRISTBAND',
    PHONE = 'PHONE',
}

export class LinkDeviceDto {
    @IsString()
    @IsNotEmpty()
    deviceUid: string;

    @IsEnum(DeviceType)
    deviceType: DeviceType;

    @IsString()
    @IsOptional()
    label?: string;
}
