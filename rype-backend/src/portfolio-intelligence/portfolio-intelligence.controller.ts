import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PortfolioIntelligenceService } from './portfolio-intelligence.service';
import { WhatIfSellAmountDto } from './dto/what-if-sell-amount.dto';

@Controller('portfolio-intelligence')
@UseGuards(JwtAuthGuard)
export class PortfolioIntelligenceController {
  constructor(
    private portfolioIntelligenceService: PortfolioIntelligenceService,
  ) {}

  @Get('insights')
  getInsights(@Req() req) {
    return this.portfolioIntelligenceService.generateInsights(req.user.userId);
  }

  @Get('redemption')
  getRedemptionRecommendations(@Req() req) {
    return this.portfolioIntelligenceService.getRedemptionRecommendations(
      req.user.userId,
    );
  }

  @Post('what-if/sell-amount')
  simulateSellAmount(@Req() req, @Body() body: WhatIfSellAmountDto) {
    return this.portfolioIntelligenceService.simulateSellAmount(
      req.user.userId,
      body.amount,
    );
  }

  @Get('alerts')
  getAlerts(@Req() req) {
    return this.portfolioIntelligenceService.getAiAlerts(req.user.userId);
  }

  @Get('metrics')
  getAdvancedMetrics(@Req() req) {
    return this.portfolioIntelligenceService.getAdvancedMetrics(req.user.userId);
  }

  @Get('future-architecture')
  getFutureArchitecture() {
    return this.portfolioIntelligenceService.getFutureArchitecture();
  }
}
