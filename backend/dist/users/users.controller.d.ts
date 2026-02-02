import { UsersService } from './users.service';
import { UpdateProfileDto, UpdatePinDto } from './dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
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
}
