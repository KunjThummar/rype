import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { TaxReportService } from './tax-report.service';

@Controller('tax-report')
export class TaxReportController {
  constructor(private taxReportService: TaxReportService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getSummary(@Req() req) {
    return this.taxReportService.getSummary(req.user.userId);
  }
}
