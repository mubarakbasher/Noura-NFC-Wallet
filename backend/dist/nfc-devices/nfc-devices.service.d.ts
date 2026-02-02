import { PrismaService } from '../prisma/prisma.service';
import { LinkDeviceDto } from './dto';
export declare class NfcDevicesService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    linkDevice(userId: string, dto: LinkDeviceDto): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        deviceUid: string;
        deviceType: string;
        label: string | null;
        lastUsedAt: Date | null;
    }>;
    getLinkedDevices(userId: string): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        deviceUid: string;
        deviceType: string;
        label: string | null;
        lastUsedAt: Date | null;
    }[]>;
    unlinkDevice(userId: string, deviceId: string): Promise<{
        message: string;
    }>;
    getDeviceByUid(deviceUid: string): Promise<{
        user: {
            wallet: {
                id: string;
                status: string;
                createdAt: Date;
                updatedAt: Date;
                userId: string;
                balance: number;
                currency: string;
            } | null;
        } & {
            email: string;
            fullName: string;
            phone: string | null;
            deviceId: string | null;
            language: string;
            id: string;
            passwordHash: string;
            pinHash: string | null;
            role: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        deviceUid: string;
        deviceType: string;
        label: string | null;
        lastUsedAt: Date | null;
    }>;
    updateDeviceUsage(deviceId: string): Promise<void>;
}
