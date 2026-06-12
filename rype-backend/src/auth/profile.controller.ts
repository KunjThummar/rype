import { Controller, Get, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('profile')
export class ProfileController {
  @UseGuards(JwtAuthGuard)
  @Get()
  getProfile(@Req() req) {
    return {
      success: true,
      user: req.user,
    };
  }
}
