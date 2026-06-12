import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { BenchmarkService } from '../benchmark/benchmark.service';

@Injectable()
export class DashboardService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mfModel: Model<MutualFundDocument>,

    private benchmarkService: BenchmarkService,
  ) {}

  async getSummary(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    const mutualFunds = await this.mfModel.find({
      userId,
    });

    const stockInvestment = stocks.reduce(
      (sum, stock) => sum + stock.investmentAmount,
      0,
    );

    const stockCurrentValue = stocks.reduce(
      (sum, stock) => sum + stock.currentValue,
      0,
    );

    const stockProfit = stocks.reduce(
      (sum, stock) => sum + stock.profitLoss,
      0,
    );

    const mfInvestment = mutualFunds.reduce(
      (sum, mf) => sum + mf.investmentAmount,
      0,
    );

    const mfCurrentValue = mutualFunds.reduce(
      (sum, mf) => sum + mf.currentValue,
      0,
    );

    const mfProfit = mutualFunds.reduce((sum, mf) => sum + mf.profitLoss, 0);

    const totalInvestment = stockInvestment + mfInvestment;

    const currentValue = stockCurrentValue + mfCurrentValue;

    const totalProfitLoss = stockProfit + mfProfit;

    const profitPercentage =
      totalInvestment > 0
        ? ((totalProfitLoss / totalInvestment) * 100).toFixed(2)
        : 0;

    const benchmarks = await this.benchmarkService.getBenchmarks();

    const portfolioReturn =
      totalInvestment > 0
        ? Number(((totalProfitLoss / totalInvestment) * 100).toFixed(2))
        : 0;

    const outperformedNifty = portfolioReturn > benchmarks.nifty50.yearlyReturn;

    const outperformedSensex = portfolioReturn > benchmarks.sensex.yearlyReturn;

    const assets = [
      ...stocks.map((stock) => ({
        name: stock.symbol,
        profitLoss: stock.profitLoss,
        currentValue: stock.currentValue,
        type: 'STOCK',
      })),

      ...mutualFunds.map((fund) => ({
        name: fund.fundName,
        profitLoss: fund.profitLoss,
        currentValue: fund.currentValue,
        type: 'MF',
      })),
    ];

    const sortedAssets = [...assets].sort(
      (a, b) => b.profitLoss - a.profitLoss,
    );

    const topGainer = sortedAssets.length > 0 ? sortedAssets[0] : null;

    const topLoser =
      sortedAssets.length > 0 ? sortedAssets[sortedAssets.length - 1] : null;

    const stockAllocation =
      currentValue > 0
        ? Number(((stockCurrentValue / currentValue) * 100).toFixed(2))
        : 0;

    const mutualFundAllocation =
      currentValue > 0
        ? Number(((mfCurrentValue / currentValue) * 100).toFixed(2))
        : 0;

    return {
      totalInvestment,

      currentValue,

      totalProfitLoss,

      profitPercentage,

      totalStocks: stocks.length,

      totalMutualFunds: mutualFunds.length,

      topGainer,

      topLoser,

      allocation: {
        stocks: stockAllocation,

        mutualFunds: mutualFundAllocation,
      },

      stocks: {
        investment: stockInvestment,

        currentValue: stockCurrentValue,

        profitLoss: stockProfit,
      },

      mutualFunds: {
        investment: mfInvestment,

        currentValue: mfCurrentValue,

        profitLoss: mfProfit,
      },

      benchmarkComparison: {
        portfolioReturn,

        niftyReturn: benchmarks.nifty50.yearlyReturn,

        sensexReturn: benchmarks.sensex.yearlyReturn,

        outperformedNifty,

        outperformedSensex,
      },
    };
  }
}
