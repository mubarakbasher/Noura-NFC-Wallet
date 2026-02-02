import {
    Injectable,
    NotFoundException,
    BadRequestException,
    ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TopUpDto } from './dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class WalletsService {
    constructor(private readonly prisma: PrismaService) { }

    async getWallet(userId: string) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        return wallet;
    }

    async getBalance(userId: string) {
        const wallet = await this.getWallet(userId);
        return {
            balance: wallet.balance,
            currency: wallet.currency,
            status: wallet.status,
        };
    }

    async topUp(userId: string, topUpDto: TopUpDto) {
        const wallet = await this.getWallet(userId);

        if (wallet.status !== 'ACTIVE') {
            throw new ForbiddenException('Wallet is suspended');
        }

        // Update balance atomically
        const updatedWallet = await this.prisma.wallet.update({
            where: { id: wallet.id },
            data: {
                balance: {
                    increment: topUpDto.amount,
                },
            },
        });

        // Create a top-up transaction record
        await this.prisma.transaction.create({
            data: {
                payerWalletId: wallet.id, // Top-up to self
                merchantWalletId: wallet.id,
                amount: topUpDto.amount,
                currency: wallet.currency,
                type: 'TOPUP',
                status: 'COMPLETED',
                completedAt: new Date(),
                metadata: JSON.stringify({
                    reference: topUpDto.reference || 'manual_topup',
                }),
            },
        });

        return updatedWallet;
    }

    async debit(walletId: string, amount: number) {
        return this.prisma.$transaction(async (tx) => {
            // Lock the wallet row for update
            const wallet = await tx.wallet.findUnique({
                where: { id: walletId },
            });

            if (!wallet) {
                throw new NotFoundException('Wallet not found');
            }

            if (wallet.status !== 'ACTIVE') {
                throw new ForbiddenException('Wallet is suspended');
            }

            const currentBalance = Number(wallet.balance);
            if (currentBalance < amount) {
                throw new BadRequestException('Insufficient balance');
            }

            // Debit the wallet
            return tx.wallet.update({
                where: { id: walletId },
                data: {
                    balance: {
                        decrement: amount,
                    },
                },
            });
        });
    }

    async credit(walletId: string, amount: number) {
        return this.prisma.$transaction(async (tx) => {
            const wallet = await tx.wallet.findUnique({
                where: { id: walletId },
            });

            if (!wallet) {
                throw new NotFoundException('Wallet not found');
            }

            if (wallet.status !== 'ACTIVE') {
                throw new ForbiddenException('Wallet is suspended');
            }

            // Credit the wallet
            return tx.wallet.update({
                where: { id: walletId },
                data: {
                    balance: {
                        increment: amount,
                    },
                },
            });
        });
    }

    async getWalletById(walletId: string) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { id: walletId },
            include: { user: true },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        return wallet;
    }
}
