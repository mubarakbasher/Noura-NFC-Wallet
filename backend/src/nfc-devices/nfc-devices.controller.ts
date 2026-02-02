import {
    Controller,
    Post,
    Get,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { NfcDevicesService } from './nfc-devices.service';
import { LinkDeviceDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('api/nfc-devices')
@UseGuards(JwtAuthGuard)
export class NfcDevicesController {
    constructor(private readonly nfcDevicesService: NfcDevicesService) { }

    @Post()
    @HttpCode(HttpStatus.CREATED)
    async linkDevice(
        @CurrentUser('id') userId: string,
        @Body() dto: LinkDeviceDto,
    ) {
        return this.nfcDevicesService.linkDevice(userId, dto);
    }

    @Get()
    @HttpCode(HttpStatus.OK)
    async getLinkedDevices(@CurrentUser('id') userId: string) {
        return this.nfcDevicesService.getLinkedDevices(userId);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    async unlinkDevice(
        @CurrentUser('id') userId: string,
        @Param('id') deviceId: string,
    ) {
        return this.nfcDevicesService.unlinkDevice(userId, deviceId);
    }
}
