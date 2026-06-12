import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';

import { PortfolioService } from './portfolio.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('portfolio')
export class PortfolioController {
  constructor(private portfolioService: PortfolioService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body) {
    return this.portfolioService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getMyPortfolio(@Req() req) {
    return this.portfolioService.findByUser(req.user.userId);
  }

  @Get('summary')
  @UseGuards(JwtAuthGuard)
  getSummary(@Req() req) {
    return this.portfolioService.getSummary(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  update(@Param('id') id: string, @Body() body) {
    return this.portfolioService.update(id, body);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.portfolioService.delete(id);
  }

  @Post('recalculate')
  @UseGuards(JwtAuthGuard)
  recalculate(@Req() req) {
    return this.portfolioService.recalculatePortfolio(req.user.userId);
  }
}
