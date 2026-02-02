import { Module } from '@nestjs/common';
import { NfcDevicesService } from './nfc-devices.service';
import { NfcDevicesController } from './nfc-devices.controller';

@Module({
    controllers: [NfcDevicesController],
    providers: [NfcDevicesService],
    exports: [NfcDevicesService],
})
export class NfcDevicesModule { }
