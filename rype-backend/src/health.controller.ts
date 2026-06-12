import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get()
  getHealth() {
    return {
      success: true,
      message: 'Rype Backend Running',
    };
  }
}
