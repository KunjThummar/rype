import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { RecommendationsService } from './recommendations.service';

@Controller('recommendations')
export class RecommendationsController {
  constructor(private recommendationService: RecommendationsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getRecommendations(@Req() req) {
    return this.recommendationService.getRecommendations(req.user.userId);
  }
}
