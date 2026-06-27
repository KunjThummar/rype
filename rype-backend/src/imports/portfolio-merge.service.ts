import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { PortfolioService } from '../portfolio/portfolio.service';
import { Stock, StockDocument } from '../stocks/schemas/stock.schema';
import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

export interface MergeTransaction {
  userId: string;
  symbol: string;
  assetName?: string;
  assetType: string;
  quantity: number;
  buyPrice: number;
}

@Injectable()
export class PortfolioMergeService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mutualFundModel: Model<MutualFundDocument>,

    private portfolioService: PortfolioService,
  ) {}

  async merge(userId: string, transactions: MergeTransaction[]) {
    const stockRows = new Map<string, MergeTransaction[]>();
    const fundRows = new Map<string, MergeTransaction[]>();

    for (const transaction of transactions) {
      const symbol = transaction.symbol.toUpperCase();
      if (transaction.assetType === 'STOCK') {
        stockRows.set(symbol, [...(stockRows.get(symbol) ?? []), transaction]);
      }
      if (transaction.assetType === 'MUTUAL_FUND') {
        fundRows.set(symbol, [...(fundRows.get(symbol) ?? []), transaction]);
      }
    }

    for (const [symbol, rows] of stockRows.entries()) {
      await this.mergeStock(userId, symbol, rows);
    }

    for (const [fundName, rows] of fundRows.entries()) {
      await this.mergeMutualFund(userId, fundName, rows);
    }

    await this.portfolioService.recalculatePortfolio(userId);
  }

  private async mergeStock(
    userId: string,
    symbol: string,
    rows: MergeTransaction[],
  ) {
    const existingStocks = await this.stockModel.find({ userId, symbol });
    const existingQuantity = existingStocks.reduce(
      (sum, stock) => sum + stock.quantity,
      0,
    );
    const existingInvestment = existingStocks.reduce(
      (sum, stock) => sum + stock.buyPrice * stock.quantity,
      0,
    );
    const importedQuantity = rows.reduce((sum, row) => sum + row.quantity, 0);
    const importedInvestment = rows.reduce(
      (sum, row) => sum + row.quantity * row.buyPrice,
      0,
    );

    const quantity = existingQuantity + importedQuantity;
    if (quantity <= 0) return;

    const investmentAmount = existingInvestment + importedInvestment;
    const averageBuyPrice = investmentAmount / quantity;
    const currentPrice =
      existingStocks.find((stock) => stock.currentPrice > 0)?.currentPrice ??
      averageBuyPrice;
    const currentValue = currentPrice * quantity;
    const profitLoss = currentValue - investmentAmount;
    const profitPercent =
      investmentAmount > 0 ? (profitLoss / investmentAmount) * 100 : 0;

    const payload = {
      userId,
      stockName: existingStocks[0]?.stockName ?? symbol,
      symbol,
      quantity,
      buyPrice: averageBuyPrice,
      currentPrice,
      investmentAmount,
      currentValue,
      profitLoss,
      profitPercent,
    };

    if (existingStocks.length === 0) {
      await this.stockModel.create(payload);
      return;
    }

    const [primary, ...duplicates] = existingStocks;
    await this.stockModel.findByIdAndUpdate(primary._id, payload, {
      new: true,
    });

    if (duplicates.length > 0) {
      await this.stockModel.deleteMany({
        _id: { $in: duplicates.map((stock) => stock._id) },
      });
    }
  }

  private async mergeMutualFund(
    userId: string,
    fundName: string,
    rows: MergeTransaction[],
  ) {
    const existingFunds = await this.mutualFundModel.find({
      userId,
      fundName,
    });
    const existingUnits = existingFunds.reduce((sum, fund) => sum + fund.units, 0);
    const existingInvestment = existingFunds.reduce(
      (sum, fund) => sum + fund.purchaseNav * fund.units,
      0,
    );
    const importedUnits = rows.reduce((sum, row) => sum + row.quantity, 0);
    const importedInvestment = rows.reduce(
      (sum, row) => sum + row.quantity * row.buyPrice,
      0,
    );

    const units = existingUnits + importedUnits;
    if (units <= 0) return;

    const investmentAmount = existingInvestment + importedInvestment;
    const purchaseNav = investmentAmount / units;
    const currentNav =
      existingFunds.find((fund) => fund.currentNav > 0)?.currentNav ?? purchaseNav;
    const currentValue = currentNav * units;
    const profitLoss = currentValue - investmentAmount;
    const profitPercent =
      investmentAmount > 0 ? (profitLoss / investmentAmount) * 100 : 0;

    const payload = {
      userId,
      fundName: rows[0]?.assetName ?? fundName,
      units,
      purchaseNav,
      currentNav,
      investmentAmount,
      currentValue,
      profitLoss,
      profitPercent,
    };

    if (existingFunds.length === 0) {
      await this.mutualFundModel.create(payload);
      return;
    }

    const [primary, ...duplicates] = existingFunds;
    await this.mutualFundModel.findByIdAndUpdate(primary._id, payload, {
      new: true,
    });

    if (duplicates.length > 0) {
      await this.mutualFundModel.deleteMany({
        _id: { $in: duplicates.map((fund) => fund._id) },
      });
    }
  }
}
