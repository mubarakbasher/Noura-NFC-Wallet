import {
    Controller,
    Get,
    Post,
    Body,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { WalletsService } from './wallets.service';
import { TopUpDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('api/wallet')
@UseGuards(JwtAuthGuard)
export class WalletsController {
    constructor(private readonly walletsService: WalletsService) { }

    @Get()
    @HttpCode(HttpStatus.OK)
    async getWallet(@CurrentUser('id') userId: string) {
        return this.walletsService.getWallet(userId);
    }

    @Get('balance')
    @HttpCode(HttpStatus.OK)
    async getBalance(@CurrentUser('id') userId: string) {
        return this.walletsService.getBalance(userId);
    }

    @Post('topup')
    @HttpCode(HttpStatus.OK)
    async topUp(
        @CurrentUser('id') userId: string,
        @Body() topUpDto: TopUpDto,
    ) {
        return this.walletsService.topUp(userId, topUpDto);
    }
}
