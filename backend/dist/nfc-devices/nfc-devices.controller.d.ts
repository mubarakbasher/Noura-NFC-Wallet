import { NfcDevicesService } from './nfc-devices.service';
import { LinkDeviceDto } from './dto';
export declare class NfcDevicesController {
    private readonly nfcDevicesService;
    constructor(nfcDevicesService: NfcDevicesService);
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
}
