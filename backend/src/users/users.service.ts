import {
    Injectable,
    NotFoundException,
    BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto, UpdatePinDto } from './dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
    private readonly SALT_ROUNDS = 12;

    constructor(private readonly prisma: PrismaService) { }

    async getProfile(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { wallet: true },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        // Sanitize response
        const { passwordHash, pinHash, ...sanitized } = user;
        return sanitized;
    }

    async updateProfile(userId: string, dto: UpdateProfileDto) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        const updatedUser = await this.prisma.user.update({
            where: { id: userId },
            data: {
                fullName: dto.fullName ?? user.fullName,
                phone: dto.phone ?? user.phone,
                language: dto.language ?? user.language,
            },
            include: { wallet: true },
        });

        const { passwordHash, pinHash, ...sanitized } = updatedUser;
        return sanitized;
    }

    async updatePin(userId: string, dto: UpdatePinDto) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
        });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        // If user already has a PIN, verify the current PIN
        if (user.pinHash && dto.currentPin) {
            const isPinValid = await bcrypt.compare(dto.currentPin, user.pinHash);
            if (!isPinValid) {
                throw new BadRequestException('Current PIN is incorrect');
            }
        }

        // Hash new PIN
        const pinHash = await bcrypt.hash(dto.pin, this.SALT_ROUNDS);

        await this.prisma.user.update({
            where: { id: userId },
            data: { pinHash },
        });

        return { message: 'PIN updated successfully' };
    }

    async verifyPin(userId: string, pin: string): Promise<boolean> {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
        });

        if (!user || !user.pinHash) {
            return false;
        }

        return bcrypt.compare(pin, user.pinHash);
    }
}
