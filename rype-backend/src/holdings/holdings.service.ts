import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  Transaction,
  TransactionDocument,
} from '../transactions/schemas/transaction.schema';

@Injectable()
export class HoldingsService {
  constructor(
    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,

    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,
  ) {}

  async getHoldingsSummary(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    const grouped = {};

    for (const stock of stocks) {
      if (!grouped[stock.symbol]) {
        grouped[stock.symbol] = {
          symbol: stock.symbol,

          quantity: 0,

          investmentValue: 0,

          currentValue: 0,

          currentPrice: stock.currentPrice,
        };
      }

      grouped[stock.symbol].quantity += stock.quantity;

      grouped[stock.symbol].investmentValue += stock.buyPrice * stock.quantity;

      grouped[stock.symbol].currentValue += stock.currentPrice * stock.quantity;
    }

    return Object.values(grouped).map((holding: any) => {
      const averageBuyPrice = holding.investmentValue / holding.quantity;

      const profitLoss = holding.currentValue - holding.investmentValue;

      return {
        symbol: holding.symbol,

        quantity: holding.quantity,

        averageBuyPrice,

        currentPrice: holding.currentPrice,

        investmentValue: holding.investmentValue,

        currentValue: holding.currentValue,

        profitLoss,

        profitLossPercent: (
          (profitLoss / holding.investmentValue) *
          100
        ).toFixed(2),
      };
    });
  }

  async getHoldings(userId: string) {
    const transactions = await this.transactionModel.find({
      userId,
    });

    const holdingsMap = new Map();

    for (const tx of transactions) {
      const symbol = tx.symbol;

      if (!holdingsMap.has(symbol)) {
        holdingsMap.set(symbol, {
          symbol,
          assetName: tx.assetName,
          quantity: 0,
          totalCost: 0,
        });
      }

      const holding = holdingsMap.get(symbol);

      if (tx.transactionType === 'BUY') {
        holding.quantity += tx.quantity;

        holding.totalCost += tx.quantity * tx.price;
      }

      if (tx.transactionType === 'SELL') {
        const avgPrice =
          holding.quantity > 0 ? holding.totalCost / holding.quantity : 0;

        holding.quantity -= tx.quantity;

        holding.totalCost -= avgPrice * tx.quantity;
      }
    }

    const holdings = Array.from(holdingsMap.values()).map((holding: any) => ({
      symbol: holding.symbol,
      assetName: holding.assetName,
      quantity: holding.quantity,

      averageBuyPrice:
        holding.quantity > 0
          ? Number((holding.totalCost / holding.quantity).toFixed(2))
          : 0,

      investedAmount: Number(holding.totalCost.toFixed(2)),
    }));

    return holdings;
  }
}
