"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NfcDevicesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let NfcDevicesService = class NfcDevicesService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async linkDevice(userId, dto) {
        const existingDevice = await this.prisma.nfcDevice.findUnique({
            where: { deviceUid: dto.deviceUid },
        });
        if (existingDevice) {
            if (existingDevice.userId === userId) {
                throw new common_1.ConflictException('Device is already linked to your account');
            }
            throw new common_1.ConflictException('Device is already linked to another account');
        }
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
    async getLinkedDevices(userId) {
        return this.prisma.nfcDevice.findMany({
            where: {
                userId,
                status: { not: 'REVOKED' },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async unlinkDevice(userId, deviceId) {
        const device = await this.prisma.nfcDevice.findUnique({
            where: { id: deviceId },
        });
        if (!device) {
            throw new common_1.NotFoundException('Device not found');
        }
        if (device.userId !== userId) {
            throw new common_1.NotFoundException('Device not found');
        }
        await this.prisma.nfcDevice.update({
            where: { id: deviceId },
            data: { status: 'REVOKED' },
        });
        return { message: 'Device unlinked successfully' };
    }
    async getDeviceByUid(deviceUid) {
        const device = await this.prisma.nfcDevice.findUnique({
            where: { deviceUid },
            include: { user: { include: { wallet: true } } },
        });
        if (!device || device.status !== 'ACTIVE') {
            throw new common_1.NotFoundException('Device not found or inactive');
        }
        return device;
    }
    async updateDeviceUsage(deviceId) {
        await this.prisma.nfcDevice.update({
            where: { id: deviceId },
            data: { lastUsedAt: new Date() },
        });
    }
};
exports.NfcDevicesService = NfcDevicesService;
exports.NfcDevicesService = NfcDevicesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], NfcDevicesService);
//# sourceMappingURL=nfc-devices.service.js.map