import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { TaxDashboardService } from './tax-dashboard.service';

@Controller('tax-dashboard')
export class TaxDashboardController {
  constructor(private dashboardService: TaxDashboardService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getDashboard(@Req() req) {
    return this.dashboardService.getDashboard(req.user.userId);
  }
}
