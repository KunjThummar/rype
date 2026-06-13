import { Controller, Get } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';

@Controller()
export class HealthController {
  constructor(@InjectConnection() private readonly connection: Connection) {}

  @Get()
  getHealth() {
    return {
      success: true,
      message: 'Rype Backend Running',
      database: this.getDatabaseStatus(),
    };
  }

  @Get('health')
  getDetailedHealth() {
    const database = this.getDatabaseStatus();

    return {
      success: database.connected,
      message: database.connected
        ? 'Rype Backend and database are running'
        : 'Rype Backend is running, but database is not connected',
      database,
    };
  }

  private getDatabaseStatus() {
    const states = ['disconnected', 'connected', 'connecting', 'disconnecting'];
    const readyState = this.connection.readyState;

    return {
      connected: readyState === 1,
      state: states[readyState] ?? 'unknown',
    };
  }
}
