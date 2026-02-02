import {
    Controller,
    Post,
    Get,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { TransactionsService } from './transactions.service';
import { ValidateTransactionDto, TransactionHistoryDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('api/transaction')
@UseGuards(JwtAuthGuard)
export class TransactionsController {
    constructor(private readonly transactionsService: TransactionsService) { }

    @Post('validate')
    @UseGuards(RolesGuard)
    @Roles('MERCHANT', 'USER')
    @HttpCode(HttpStatus.OK)
    async validateAndProcessTransaction(
        @CurrentUser('id') userId: string,
        @Body() dto: ValidateTransactionDto,
    ) {
        return this.transactionsService.validateAndProcessTransaction(userId, dto);
    }

    @Get('history')
    @HttpCode(HttpStatus.OK)
    async getTransactionHistory(
        @CurrentUser('id') userId: string,
        @Query() dto: TransactionHistoryDto,
    ) {
        return this.transactionsService.getTransactionHistory(userId, dto);
    }

    @Get(':id')
    @HttpCode(HttpStatus.OK)
    async getTransactionById(
        @CurrentUser('id') userId: string,
        @Param('id') transactionId: string,
    ) {
        return this.transactionsService.getTransactionById(userId, transactionId);
    }
}
