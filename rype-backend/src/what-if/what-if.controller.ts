import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { WhatIfService } from './what-if.service';

import { WhatIfDto } from './dto/what-if.dto';

@Controller('what-if')
export class WhatIfController {
  constructor(private whatIfService: WhatIfService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  analyze(@Req() req, @Body() body: WhatIfDto) {
    return this.whatIfService.analyze(
      req.user.userId,
      body.symbol,
      body.quantity,
      body.sellPrice,
    );
  }
}
