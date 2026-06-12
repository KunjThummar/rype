import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { HoldingsService } from './holdings.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('holdings')
export class HoldingsController {
  constructor(private holdingsService: HoldingsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getHoldings(@Req() req) {
    return this.holdingsService.getHoldings(req.user.userId);
  }
}
