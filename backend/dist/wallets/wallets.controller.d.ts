import { WalletsService } from './wallets.service';
import { TopUpDto } from './dto';
export declare class WalletsController {
    private readonly walletsService;
    constructor(walletsService: WalletsService);
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
}
