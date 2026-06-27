import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';
import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';
import { TaxLot, TaxLotDocument } from '../tax-lots/schemas/tax-lot.schema';
import {
  Dividend,
  DividendDocument,
} from '../dividends/schemas/dividend.schema';
import {
  Transaction,
  TransactionDocument,
} from '../transactions/schemas/transaction.schema';
import {
  PortfolioInsight,
  PortfolioInsightDocument,
} from './schemas/portfolio-insight.schema';

@Injectable()
export class PortfolioIntelligenceService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mutualFundModel: Model<MutualFundDocument>,

    @InjectModel(TaxLot.name)
    private taxLotModel: Model<TaxLotDocument>,

    @InjectModel(Dividend.name)
    private dividendModel: Model<DividendDocument>,

    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,

    @InjectModel(PortfolioInsight.name)
    private insightModel: Model<PortfolioInsightDocument>,
  ) {}

  async generateInsights(userId: string) {
    const { stocks, funds } = await this.getAssets(userId);
    const totalCurrentValue = this.totalCurrentValue(stocks, funds);
    const totalInvestment = this.totalInvestment(stocks, funds);
    const totalProfitLoss = totalCurrentValue - totalInvestment;
    const roi =
      totalInvestment > 0 ? (totalProfitLoss / totalInvestment) * 100 : 0;
    const largestAssetPercent = this.largestAssetPercent(stocks, funds);
    const stockAllocation =
      totalCurrentValue > 0
        ? (stocks.reduce((sum, stock) => sum + stock.currentValue, 0) /
            totalCurrentValue) *
          100
        : 0;
    const assetCount = stocks.length + funds.length;
    const diversificationScore = Math.max(
      0,
      Math.min(100, assetCount * 8 - Math.max(0, largestAssetPercent - 25)),
    );
    const riskScore = Math.max(
      0,
      Math.min(
        100,
        stockAllocation * 0.65 + largestAssetPercent * 0.35 - assetCount,
      ),
    );
    const concentrationRisk =
      largestAssetPercent > 35
        ? 'HIGH'
        : largestAssetPercent > 20
          ? 'MEDIUM'
          : 'LOW';
    const portfolioHealthScore = Math.round(
      Math.max(
        0,
        Math.min(
          100,
          55 + diversificationScore * 0.3 + roi * 0.4 - riskScore * 0.25,
        ),
      ),
    );

    const taxOptimizationSuggestions =
      await this.getTaxOptimizationSuggestions(userId);

    const insights = {
      portfolioHealthScore,
      riskScore: Math.round(riskScore),
      sectorConcentrationRisk: concentrationRisk,
      diversificationScore: Math.round(diversificationScore),
      taxOptimizationSuggestions,
      metrics: {
        totalCurrentValue,
        totalInvestment,
        totalProfitLoss,
        roi: Number(roi.toFixed(2)),
        largestAssetPercent: Number(largestAssetPercent.toFixed(2)),
      },
    };

    await this.insightModel.create({ userId, insights });
    return insights;
  }

  async getRedemptionRecommendations(userId: string) {
    const { stocks, funds } = await this.getAssets(userId);
    const totalCurrentValue = this.totalCurrentValue(stocks, funds);
    const rows = [...stocks, ...funds].map((asset: any) => {
      const currentValue = asset.currentValue ?? 0;
      const profitPercent = asset.profitPercent ?? 0;
      const allocation =
        totalCurrentValue > 0 ? (currentValue / totalCurrentValue) * 100 : 0;
      const taxImpact = profitPercent > 0 ? profitPercent * 0.15 : 0;
      let action = 'HOLD';
      let reason = 'Allocation and tax impact are acceptable';

      if (profitPercent >= 30 && allocation >= 20) {
        action = 'PARTIAL_SELL';
        reason = 'High profit and concentrated allocation';
      } else if (profitPercent <= -15) {
        action = 'HOLD';
        reason = 'Loss position requires review before exit';
      } else if (profitPercent >= 45) {
        action = 'SELL';
        reason = 'Large unrealized gain may be booked gradually';
      }

      return {
        assetType: asset.symbol ? 'STOCK' : 'MUTUAL_FUND',
        symbol: asset.symbol ?? asset.fundName,
        action,
        reason,
        profitPercent: Number(profitPercent.toFixed(2)),
        allocation: Number(allocation.toFixed(2)),
        estimatedTaxImpactScore: Number(taxImpact.toFixed(2)),
      };
    });

    return rows;
  }

  async simulateSellAmount(userId: string, amount: number) {
    const { stocks, funds } = await this.getAssets(userId);
    const assets = [...stocks, ...funds]
      .map((asset: any) => ({
        name: asset.symbol ?? asset.fundName,
        assetType: asset.symbol ? 'STOCK' : 'MUTUAL_FUND',
        currentValue: asset.currentValue ?? 0,
        profitPercent: asset.profitPercent ?? 0,
      }))
      .sort((a, b) => b.profitPercent - a.profitPercent);

    let remaining = amount;
    const sellPlan: any[] = [];
    let estimatedTax = 0;
    let remainingGains = 0;

    for (const asset of assets) {
      if (remaining <= 0) break;
      const sellValue = Math.min(asset.currentValue, remaining);
      const gainPortion = Math.max(0, sellValue * (asset.profitPercent / 100));
      const tax = gainPortion * 0.15;
      estimatedTax += tax;
      remainingGains += Math.max(0, asset.currentValue - sellValue);
      sellPlan.push({
        ...asset,
        sellValue: Number(sellValue.toFixed(2)),
        estimatedTax: Number(tax.toFixed(2)),
      });
      remaining -= sellValue;
    }

    const totalCurrentValue = this.totalCurrentValue(stocks, funds);
    const newPortfolioValue = Math.max(0, totalCurrentValue - amount);

    return {
      requestedSellAmount: amount,
      fulfilledSellAmount: Number((amount - Math.max(0, remaining)).toFixed(2)),
      estimatedTax: Number(estimatedTax.toFixed(2)),
      netReceivable: Number((amount - estimatedTax).toFixed(2)),
      remainingPortfolioValue: Number(newPortfolioValue.toFixed(2)),
      remainingGains: Number(remainingGains.toFixed(2)),
      allocationAfterSale: this.allocationAfterSale(stocks, funds, sellPlan),
      sellPlan,
    };
  }

  async getAiAlerts(userId: string) {
    const { stocks, funds } = await this.getAssets(userId);
    const assets = [...stocks, ...funds] as any[];
    const alerts: any[] = [];
    const totalCurrentValue = this.totalCurrentValue(stocks, funds);

    for (const asset of assets) {
      const name = asset.symbol ?? asset.fundName;
      const allocation =
        totalCurrentValue > 0 ? ((asset.currentValue ?? 0) / totalCurrentValue) * 100 : 0;

      if ((asset.profitPercent ?? 0) >= 25) {
        alerts.push({
          type: 'PROFIT_TARGET_REACHED',
          symbol: name,
          message: `${name} has crossed the profit target threshold.`,
        });
      }
      if ((asset.profitPercent ?? 0) <= -12) {
        alerts.push({
          type: 'LOSS_THRESHOLD_REACHED',
          symbol: name,
          message: `${name} has crossed the loss threshold.`,
        });
      }
      if (allocation >= 30) {
        alerts.push({
          type: 'REBALANCING_OPPORTUNITY',
          symbol: name,
          message: `${name} is a concentrated position.`,
        });
      }
    }

    const taxSuggestions = await this.getTaxOptimizationSuggestions(userId);
    for (const suggestion of taxSuggestions) {
      alerts.push({
        type: 'TAX_SAVING_OPPORTUNITY',
        symbol: suggestion.symbol,
        message: suggestion.message,
      });
    }

    return alerts;
  }

  async getAdvancedMetrics(userId: string) {
    const { stocks, funds } = await this.getAssets(userId);
    const transactions = await this.transactionModel
      .find({ userId })
      .sort({ transactionDate: 1 });
    const dividends = await this.dividendModel.find({ userId });
    const currentValue = this.totalCurrentValue(stocks, funds);
    const totalInvestment = this.totalInvestment(stocks, funds);
    const totalDividends = dividends.reduce(
      (sum, dividend) => sum + dividend.dividendAmount,
      0,
    );

    return {
      assetAllocationCharts: this.assetAllocation(stocks, funds),
      dividendTracking: {
        totalDividends,
        dividendCount: dividends.length,
      },
      xirr: this.estimateXirr(transactions, currentValue),
      cagr: this.estimateCagr(transactions, totalInvestment, currentValue),
    };
  }

  getFutureArchitecture() {
    return {
      brokerApiSync: {
        status: 'prepared',
        modules: ['broker-auth-adapters', 'broker-sync-jobs', 'sync-audit-log'],
      },
      casAutoEmailImport: {
        status: 'prepared',
        modules: ['mailbox-ingestion', 'cas-attachment-parser', 'dedupe-engine'],
      },
      wealthTracking: {
        status: 'prepared',
        modules: ['net-worth-ledger', 'external-assets', 'liabilities'],
      },
      familyPortfolioManagement: {
        status: 'prepared',
        modules: ['family-groups', 'member-permissions', 'consolidated-view'],
      },
    };
  }

  private async getAssets(userId: string) {
    const [stocks, funds] = await Promise.all([
      this.stockModel.find({ userId }),
      this.mutualFundModel.find({ userId }),
    ]);

    return { stocks, funds };
  }

  private totalCurrentValue(stocks: StockDocument[], funds: MutualFundDocument[]) {
    return (
      stocks.reduce((sum, stock) => sum + stock.currentValue, 0) +
      funds.reduce((sum, fund) => sum + fund.currentValue, 0)
    );
  }

  private totalInvestment(stocks: StockDocument[], funds: MutualFundDocument[]) {
    return (
      stocks.reduce((sum, stock) => sum + stock.investmentAmount, 0) +
      funds.reduce((sum, fund) => sum + fund.investmentAmount, 0)
    );
  }

  private largestAssetPercent(stocks: StockDocument[], funds: MutualFundDocument[]) {
    const total = this.totalCurrentValue(stocks, funds);
    if (total <= 0) return 0;
    const largest = [...stocks, ...funds].reduce(
      (max: number, asset: any) => Math.max(max, asset.currentValue ?? 0),
      0,
    );
    return (largest / total) * 100;
  }

  private async getTaxOptimizationSuggestions(userId: string) {
    const lots = await this.taxLotModel.find({
      userId,
      remainingQuantity: { $gt: 0 },
    });

    return lots
      .map((lot) => {
        const holdingDays = Math.floor(
          (Date.now() - new Date(lot.buyDate).getTime()) /
            (1000 * 60 * 60 * 24),
        );
        const daysToLtcg = Math.max(0, 365 - holdingDays);
        if (daysToLtcg === 0 || daysToLtcg > 45) return null;
        return {
          symbol: lot.symbol,
          message: `Consider waiting ${daysToLtcg} days for LTCG eligibility.`,
          daysToLtcg,
        };
      })
      .filter(
        (
          suggestion,
        ): suggestion is {
          symbol: string;
          message: string;
          daysToLtcg: number;
        } => Boolean(suggestion),
      );
  }

  private assetAllocation(stocks: StockDocument[], funds: MutualFundDocument[]) {
    const stockValue = stocks.reduce((sum, stock) => sum + stock.currentValue, 0);
    const fundValue = funds.reduce((sum, fund) => sum + fund.currentValue, 0);
    const total = stockValue + fundValue;
    return [
      {
        category: 'Stocks',
        value: stockValue,
        percentage: total > 0 ? Number(((stockValue / total) * 100).toFixed(2)) : 0,
      },
      {
        category: 'Mutual Funds',
        value: fundValue,
        percentage: total > 0 ? Number(((fundValue / total) * 100).toFixed(2)) : 0,
      },
    ];
  }

  private allocationAfterSale(
    stocks: StockDocument[],
    funds: MutualFundDocument[],
    sellPlan: any[],
  ) {
    const soldByName = new Map(
      sellPlan.map((plan) => [plan.name, plan.sellValue]),
    );
    const stockValue = stocks.reduce(
      (sum, stock) => sum + Math.max(0, stock.currentValue - (soldByName.get(stock.symbol) ?? 0)),
      0,
    );
    const fundValue = funds.reduce(
      (sum, fund) => sum + Math.max(0, fund.currentValue - (soldByName.get(fund.fundName) ?? 0)),
      0,
    );
    const total = stockValue + fundValue;
    return {
      stocks: total > 0 ? Number(((stockValue / total) * 100).toFixed(2)) : 0,
      mutualFunds: total > 0 ? Number(((fundValue / total) * 100).toFixed(2)) : 0,
    };
  }

  private estimateXirr(transactions: TransactionDocument[], currentValue: number) {
    if (transactions.length === 0 || currentValue <= 0) return 0;
    const invested = transactions
      .filter((transaction) => transaction.transactionType === 'BUY')
      .reduce((sum, transaction) => sum + transaction.quantity * transaction.price, 0);
    if (invested <= 0) return 0;
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
