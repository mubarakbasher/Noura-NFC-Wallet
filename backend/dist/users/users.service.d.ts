import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto, UpdatePinDto } from './dto';
export declare class UsersService {
    private readonly prisma;
    private readonly SALT_ROUNDS;
    constructor(prisma: PrismaService);
    getProfile(userId: string): Promise<{
        wallet: {
            id: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            balance: number;
            currency: string;
        } | null;
        email: string;
        fullName: string;
        phone: string | null;
        deviceId: string | null;
        language: string;
        id: string;
        role: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
    updateProfile(userId: string, dto: UpdateProfileDto): Promise<{
        wallet: {
            id: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            balance: number;
            currency: string;
        } | null;
        email: string;
        fullName: string;
        phone: string | null;
        deviceId: string | null;
        language: string;
        id: string;
        role: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
    updatePin(userId: string, dto: UpdatePinDto): Promise<{
        message: string;
    }>;
    verifyPin(userId: string, pin: string): Promise<boolean>;
}
