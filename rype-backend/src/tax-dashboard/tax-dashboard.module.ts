import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import {
  TaxRealization,
  TaxRealizationSchema,
} from '../tax-realizations/schemas/tax-realization.schema';

import { TaxDashboardController } from './tax-dashboard.controller';
import { TaxDashboardService } from './tax-dashboard.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: TaxRealization.name,
        schema: TaxRealizationSchema,
      },
    ]),
  ],
  controllers: [TaxDashboardController],
  providers: [TaxDashboardService],
})
export class TaxDashboardModule {}
