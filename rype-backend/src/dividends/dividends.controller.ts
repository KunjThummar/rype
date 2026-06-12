import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { DividendsService } from './dividends.service';

@Controller('dividends')
export class DividendsController {
  constructor(private dividendsService: DividendsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body) {
    return this.dividendsService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getAll(@Req() req) {
    return this.dividendsService.findAll(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('summary')
  getSummary(@Req() req) {
    return this.dividendsService.getSummary(req.user.userId);
  }
}
