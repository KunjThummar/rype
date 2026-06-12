import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { TaxRealizationsService } from './tax-realizations.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('tax-realizations')
export class TaxRealizationsController {
  constructor(private taxRealizationsService: TaxRealizationsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getAll(@Req() req) {
    return this.taxRealizationsService.findAll(req.user.userId);
  }
}
