import { PrismaService } from '../prisma/prisma.service';
import { TopUpDto } from './dto';
export declare class WalletsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getWallet(userId: string): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        balance: number;
        currency: string;
    }>;
    getBalance(userId: string): Promise<{
        balance: number;
        currency: string;
        status: string;
    }>;
    topUp(userId: string, topUpDto: TopUpDto): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        balance: number;
        currency: string;
    }>;
    debit(walletId: string, amount: number): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        balance: number;
        currency: string;
    }>;
    credit(walletId: string, amount: number): Promise<{
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        balance: number;
        currency: string;
    }>;
    getWalletById(walletId: string): Promise<{
        user: {
            email: string;
            fullName: string;
            phone: string | null;
            deviceId: string | null;
            language: string;
            id: string;
            passwordHash: string;
            pinHash: string | null;
            role: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        balance: number;
        currency: string;
    }>;
}
