import {
    Controller,
    Get,
    Put,
    Body,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto, UpdatePinDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('api/user')
@UseGuards(JwtAuthGuard)
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Get('profile')
    @HttpCode(HttpStatus.OK)
    async getProfile(@CurrentUser('id') userId: string) {
        return this.usersService.getProfile(userId);
    }

    @Put('profile')
    @HttpCode(HttpStatus.OK)
    async updateProfile(
        @CurrentUser('id') userId: string,
        @Body() dto: UpdateProfileDto,
    ) {
        return this.usersService.updateProfile(userId, dto);
    }

    @Put('pin')
    @HttpCode(HttpStatus.OK)
    async updatePin(
        @CurrentUser('id') userId: string,
        @Body() dto: UpdatePinDto,
    ) {
        return this.usersService.updatePin(userId, dto);
    }
}
