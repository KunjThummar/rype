import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello() {
    return {
      app: 'Rype API',
      version: '1.0.0',
      status: 'running',
      timestamp: new Date(),
    };
  }
}
