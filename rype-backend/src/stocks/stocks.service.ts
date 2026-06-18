import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { TransactionsService } from '../transactions/transactions.service';
import { Stock, StockDocument } from './schemas/stock.schema';

import { MarketDataService } from '../market-data/market-data.service';
import { PortfolioService } from '../portfolio/portfolio.service';

@Injectable()
export class StocksService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    private transactionsService: TransactionsService,

    private marketDataService: MarketDataService,

    private portfolioService: PortfolioService,
  ) {}

  async create(data: any) {
    const investmentAmount = data.buyPrice * data.quantity;

    const currentValue = data.currentPrice * data.quantity;

    const profitLoss = currentValue - investmentAmount;

    const profitPercent = (profitLoss / investmentAmount) * 100;

    const stock = await this.stockModel.create({
      ...data,
      investmentAmount,
      currentValue,
      profitLoss,
      profitPercent,
    });

    await this.transactionsService.create({
      userId: data.userId,

      assetType: 'STOCK',

      assetName: data.stockName,

      symbol: data.symbol,

      transactionType: 'BUY',

      quantity: data.quantity,

      price: data.buyPrice,

      transactionDate: new Date(),
    });

    await this.portfolioService.recalculatePortfolio(data.userId);

    return stock;
  }

  async findAll(userId: string) {
    return this.stockModel.find({
      userId,
    });
  }

  async findOne(id: string) {
    return this.stockModel.findById(id);
  }

  async update(id: string, body: any) {
    const stock = await this.stockModel.findByIdAndUpdate(id, body, {
      new: true,
    });

    if (stock) {
      await this.portfolioService.recalculatePortfolio(stock.userId.toString());
    }

    return stock;
  }

  async refreshPrices(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    for (const stock of stocks) {
      const marketData = await this.marketDataService.getStockPrice(
        stock.symbol,
      );

      if (marketData.price === null || marketData.price <= 0) {
        continue;
      }

      stock.currentPrice = marketData.price;

      stock.currentValue = stock.currentPrice * stock.quantity;

      stock.profitLoss = stock.currentValue - stock.investmentAmount;

      stock.profitPercent =
        stock.investmentAmount > 0
          ? (stock.profitLoss / stock.investmentAmount) * 100
          : 0;

      stock.todaysGainLoss = (marketData.change ?? 0) * stock.quantity;

      await stock.save();
    }

    await this.portfolioService.recalculatePortfolio(userId);

    return {
      success: true,
    };
  }

  async delete(id: string) {
    const stock = await this.stockModel.findById(id);

    await this.stockModel.findByIdAndDelete(id);

    if (stock) {
      await this.portfolioService.recalculatePortfolio(stock.userId.toString());
    }

    return {
      success: true,
    };
  }
}
