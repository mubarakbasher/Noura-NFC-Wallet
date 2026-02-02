import {
    Injectable,
    NotFoundException,
    ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LinkDeviceDto } from './dto';

@Injectable()
export class NfcDevicesService {
    constructor(private readonly prisma: PrismaService) { }

    async linkDevice(userId: string, dto: LinkDeviceDto) {
        // Check if device is already linked
        const existingDevice = await this.prisma.nfcDevice.findUnique({
            where: { deviceUid: dto.deviceUid },
        });

        if (existingDevice) {
            if (existingDevice.userId === userId) {
                throw new ConflictException('Device is already linked to your account');
            }
            throw new ConflictException('Device is already linked to another account');
        }

        // Link the device
        return this.prisma.nfcDevice.create({
            data: {
                userId,
                deviceUid: dto.deviceUid,
                deviceType: dto.deviceType,
                label: dto.label,
                status: 'ACTIVE',
            },
        });
    }

    async getLinkedDevices(userId: string) {
        return this.prisma.nfcDevice.findMany({
            where: {
                userId,
                status: { not: 'REVOKED' },
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    async unlinkDevice(userId: string, deviceId: string) {
        const device = await this.prisma.nfcDevice.findUnique({
            where: { id: deviceId },
        });

        if (!device) {
            throw new NotFoundException('Device not found');
        }

        if (device.userId !== userId) {
            throw new NotFoundException('Device not found');
        }

        // Revoke the device instead of deleting
        await this.prisma.nfcDevice.update({
            where: { id: deviceId },
            data: { status: 'REVOKED' },
        });

        return { message: 'Device unlinked successfully' };
    }

    async getDeviceByUid(deviceUid: string) {
        const device = await this.prisma.nfcDevice.findUnique({
            where: { deviceUid },
            include: { user: { include: { wallet: true } } },
        });

        if (!device || device.status !== 'ACTIVE') {
            throw new NotFoundException('Device not found or inactive');
        }

        return device;
    }

    async updateDeviceUsage(deviceId: string) {
        await this.prisma.nfcDevice.update({
            where: { id: deviceId },
            data: { lastUsedAt: new Date() },
        });
    }
}
