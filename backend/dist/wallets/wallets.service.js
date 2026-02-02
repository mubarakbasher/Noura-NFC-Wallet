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
exports.WalletsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let WalletsService = class WalletsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getWallet(userId) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
        }
        return wallet;
    }
    async getBalance(userId) {
        const wallet = await this.getWallet(userId);
        return {
            balance: wallet.balance,
            currency: wallet.currency,
            status: wallet.status,
        };
    }
    async topUp(userId, topUpDto) {
        const wallet = await this.getWallet(userId);
        if (wallet.status !== 'ACTIVE') {
            throw new common_1.ForbiddenException('Wallet is suspended');
        }
        const updatedWallet = await this.prisma.wallet.update({
            where: { id: wallet.id },
            data: {
                balance: {
                    increment: topUpDto.amount,
                },
            },
        });
        await this.prisma.transaction.create({
            data: {
                payerWalletId: wallet.id,
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
    async debit(walletId, amount) {
        return this.prisma.$transaction(async (tx) => {
            const wallet = await tx.wallet.findUnique({
                where: { id: walletId },
            });
            if (!wallet) {
                throw new common_1.NotFoundException('Wallet not found');
            }
            if (wallet.status !== 'ACTIVE') {
                throw new common_1.ForbiddenException('Wallet is suspended');
            }
            const currentBalance = Number(wallet.balance);
            if (currentBalance < amount) {
                throw new common_1.BadRequestException('Insufficient balance');
            }
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
    async credit(walletId, amount) {
        return this.prisma.$transaction(async (tx) => {
            const wallet = await tx.wallet.findUnique({
                where: { id: walletId },
            });
            if (!wallet) {
                throw new common_1.NotFoundException('Wallet not found');
            }
            if (wallet.status !== 'ACTIVE') {
                throw new common_1.ForbiddenException('Wallet is suspended');
            }
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
    async getWalletById(walletId) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { id: walletId },
            include: { user: true },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
        }
        return wallet;
    }
};
exports.WalletsService = WalletsService;
exports.WalletsService = WalletsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], WalletsService);
//# sourceMappingURL=wallets.service.js.map