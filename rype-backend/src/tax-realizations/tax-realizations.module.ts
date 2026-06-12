import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import {
  TaxRealization,
  TaxRealizationSchema,
} from './schemas/tax-realization.schema';

import { TaxRealizationsController } from './tax-realizations.controller';
import { TaxRealizationsService } from './tax-realizations.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: TaxRealization.name,
        schema: TaxRealizationSchema,
      },
    ]),
  ],
  controllers: [TaxRealizationsController],
  providers: [TaxRealizationsService],
  exports: [TaxRealizationsService],
})
export class TaxRealizationsModule {}
