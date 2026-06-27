import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { BenchmarkService } from '../benchmark/benchmark.service';
import {
  Transaction,
  TransactionDocument,
} from '../transactions/schemas/transaction.schema';
import { Dividend, DividendDocument } from '../dividends/schemas/dividend.schema';

@Injectable()
export class DashboardService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mfModel: Model<MutualFundDocument>,

    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,

    @InjectModel(Dividend.name)
    private dividendModel: Model<DividendDocument>,

    private benchmarkService: BenchmarkService,
  ) {}

  async getSummary(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    const mutualFunds = await this.mfModel.find({
      userId,
    });

    const recentTransactions = await this.transactionModel
      .find({ userId })
      .sort({ transactionDate: -1 })
      .limit(5);

    const transactions = await this.transactionModel
      .find({ userId })
      .sort({ transactionDate: 1 });

    const dividends = await this.dividendModel.find({ userId });

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

    const stockTodaysGainLoss = stocks.reduce(
      (sum, stock) => sum + (stock.todaysGainLoss ?? 0),
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

    const mfTodaysGainLoss = mutualFunds.reduce(
      (sum, mf) => sum + (mf.todaysGainLoss ?? 0),
      0,
    );

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
        profitPercent: stock.profitPercent,
        currentValue: stock.currentValue,
        type: 'STOCK',
      })),

      ...mutualFunds.map((fund) => ({
        name: fund.fundName,
        profitLoss: fund.profitLoss,
        profitPercent: fund.profitPercent,
        currentValue: fund.currentValue,
        type: 'MF',
      })),
    ];

    const sortedAssets = [...assets].sort(
      (a, b) => b.profitPercent - a.profitPercent,
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

    const totalDividends = dividends.reduce(
      (sum, dividend) => sum + dividend.dividendAmount,
      0,
    );

    const xirr = this.estimateXirr(transactions, currentValue);
    const cagr = this.estimateCagr(transactions, totalInvestment, currentValue);

    return {
      totalInvestment,

      currentValue,

      totalProfitLoss,

      profitPercentage,

      todaysGainLoss: stockTodaysGainLoss + mfTodaysGainLoss,

      totalStocks: stocks.length,

      totalMutualFunds: mutualFunds.length,

      topGainer,

      topLoser,

      topGainers: sortedAssets.slice(0, 5),

      topLosers: [...sortedAssets].reverse().slice(0, 5),

      recentTransactions,

      allocation: {
        stocks: stockAllocation,

        mutualFunds: mutualFundAllocation,
      },

      assetAllocationCharts: [
        {
          category: 'Stocks',
          value: stockCurrentValue,
          percentage: stockAllocation,
        },
        {
          category: 'Mutual Funds',
          value: mfCurrentValue,
          percentage: mutualFundAllocation,
        },
      ],

      dividendTracking: {
        totalDividends,
        dividendCount: dividends.length,
      },

      xirr,

      cagr,

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

  private estimateXirr(transactions: TransactionDocument[], currentValue: number) {
    const invested = transactions
      .filter((transaction) => transaction.transactionType === 'BUY')
      .reduce((sum, transaction) => sum + transaction.quantity * transaction.price, 0);

    if (invested <= 0 || currentValue <= 0) return 0;

    return Number((((currentValue - invested) / invested) * 100).toFixed(2));
  }

  private estimateCagr(
    transactions: TransactionDocument[],
    totalInvestment: number,
    currentValue: number,
  ) {
    if (transactions.length === 0 || totalInvestment <= 0 || currentValue <= 0) {
      return 0;
    }

    const firstDate = new Date(transactions[0].transactionDate).getTime();
    const years = Math.max(
      1 / 365,
      (Date.now() - firstDate) / (1000 * 60 * 60 * 24 * 365),
    );

    return Number(
      ((Math.pow(currentValue / totalInvestment, 1 / years) - 1) * 100).toFixed(2),
    );
  }
}
