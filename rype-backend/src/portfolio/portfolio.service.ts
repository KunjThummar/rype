import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Portfolio, PortfolioDocument } from './schemas/portfolio.schema';

import { PortfolioCalculatorService } from '../portfolio-calculator/portfolio-calculator.service';

@Injectable()
export class PortfolioService {
  constructor(
    @InjectModel(Portfolio.name)
    private portfolioModel: Model<PortfolioDocument>,

    private portfolioCalculatorService: PortfolioCalculatorService,
  ) {}

  //   async create(data: any) {
  //     return this.portfolioModel.create(data);
  //   }

  async create(data: any) {
    const existingPortfolio = await this.portfolioModel.findOne({
      userId: data.userId,
    });

    if (existingPortfolio) {
      return this.portfolioModel.findByIdAndUpdate(
        existingPortfolio._id,
        data,
        { new: true },
      );
    }

    return this.portfolioModel.create(data);
  }

  async getSummary(userId: string) {
    return this.portfolioCalculatorService.calculatePortfolio(userId);
  }

  async findByUser(userId: string) {
    return this.portfolioModel.findOne({
      userId,
    });
  }

  async recalculatePortfolio(userId: string) {
    const summary =
      await this.portfolioCalculatorService.calculatePortfolio(userId);

    const existingPortfolio = await this.portfolioModel.findOne({
      userId,
    });

    if (existingPortfolio) {
      return this.portfolioModel.findByIdAndUpdate(
        existingPortfolio._id,
        {
          totalInvestment: summary.totalInvestment,

          currentValue: summary.currentValue,

          totalProfitLoss: summary.totalProfitLoss,
        },
        {
          new: true,
        },
      );
    }

    return this.portfolioModel.create({
      userId,

      totalInvestment: summary.totalInvestment,

      currentValue: summary.currentValue,

      totalProfitLoss: summary.totalProfitLoss,
    });
  }

  async update(id: string, data: any) {
    return this.portfolioModel.findByIdAndUpdate(id, data, { new: true });
  }

  async delete(id: string) {
    return this.portfolioModel.findByIdAndDelete(id);
  }
}
