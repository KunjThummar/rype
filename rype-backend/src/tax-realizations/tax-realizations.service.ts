import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import {
  TaxRealization,
  TaxRealizationDocument,
} from './schemas/tax-realization.schema';

@Injectable()
export class TaxRealizationsService {
  constructor(
    @InjectModel(TaxRealization.name)
    private realizationModel: Model<TaxRealizationDocument>,
  ) {}

  async create(data: any) {
    return this.realizationModel.create(data);
  }

  async findAll(userId: string) {
    return this.realizationModel
      .find({
        userId,
      })
      .sort({
        sellDate: -1,
      });
  }
}
