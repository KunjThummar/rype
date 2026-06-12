import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { AlertsService } from './alerts.service';

@Controller('alerts')
export class AlertsController {
  constructor(private alertsService: AlertsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body) {
    return this.alertsService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getAlerts(@Req() req) {
    return this.alertsService.getAlerts(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('check')
  checkAlerts(@Req() req) {
    return this.alertsService.evaluateAlerts(req.user.userId);
  }
}
