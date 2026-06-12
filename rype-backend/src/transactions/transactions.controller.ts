import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { TransactionsService } from './transactions.service';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { CreateTransactionDto } from './dto/create-transaction.dto';

@Controller('transactions')
export class TransactionsController {
  constructor(private transactionsService: TransactionsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req, @Body() body: CreateTransactionDto) {
    return this.transactionsService.create({
      ...body,
      userId: req.user.userId,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getAll(@Req() req) {
    return this.transactionsService.findAll(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':symbol')
  getAssetTransactions(@Req() req, @Param('symbol') symbol: string) {
    return this.transactionsService.findByAsset(req.user.userId, symbol);
  }
}
