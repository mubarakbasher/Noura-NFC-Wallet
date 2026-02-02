import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'NFC Wallet Backend API - Welcome!';
  }
}
