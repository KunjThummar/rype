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

import { MutualFundsService } from './mutual-funds.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { CreateMutualFundDto } from './dto/create-mutual-fund.dto';

@Controller('mutual-funds')
export class MutualFundsController {
  constructor(private mfService: MutualFundsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body: CreateMutualFundDto) {
    return this.mfService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getAll(@Req() req) {
    return this.mfService.findAll(req.user.userId);
  }

  @Get('nav/:amfiCode')
  getNav(
    @Param('amfiCode')
    amfiCode: string,
  ) {
    return this.mfService.getNav(amfiCode);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.mfService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  update(@Param('id') id: string, @Body() body) {
    return this.mfService.update(id, body);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.mfService.delete(id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('refresh-navs')
  refreshNavs(@Req() req) {
    return this.mfService.refreshNavs(req.user.userId);
  }
}
