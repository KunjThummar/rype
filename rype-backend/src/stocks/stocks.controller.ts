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

import { StocksService } from './stocks.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { CreateStockDto } from './dto/create-stock.dto';

@Controller('stocks')
export class StocksController {
  constructor(private stocksService: StocksService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body: CreateStockDto) {
    return this.stocksService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getAll(@Req() req) {
    return this.stocksService.findAll(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.stocksService.findOne(id);
  }

  @Post('refresh-prices')
  @UseGuards(JwtAuthGuard)
  refreshPrices(@Req() req) {
    return this.stocksService.refreshPrices(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  update(@Param('id') id: string, @Body() body) {
    return this.stocksService.update(id, body);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.stocksService.delete(id);
  }
}
