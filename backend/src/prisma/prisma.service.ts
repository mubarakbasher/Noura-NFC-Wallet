import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
    constructor() {
        super({
            log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
        });
    }

    async onModuleInit() {
        await this.$connect();
    }

    async onModuleDestroy() {
        await this.$disconnect();
    }

    async cleanDatabase() {
        if (process.env.NODE_ENV !== 'test') {
            throw new Error('cleanDatabase can only be used in test environment');
        }
        // Truncate all tables in correct order (respecting foreign keys)
        await this.$transaction([
            this.usedNonce.deleteMany(),
            this.transaction.deleteMany(),
            this.refreshToken.deleteMany(),
            this.nfcDevice.deleteMany(),
            this.wallet.deleteMany(),
            this.user.deleteMany(),
        ]);
    }
}
