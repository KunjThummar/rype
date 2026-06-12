import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { TaxLot, TaxLotSchema } from './schemas/tax-lot.schema';

import { TaxLotsService } from './tax-lots.service';
import { TaxLotsController } from './tax-lots.controller';
import { TaxRealizationsModule } from '../tax-realizations/tax-realizations.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: TaxLot.name,
        schema: TaxLotSchema,
      },
    ]),
    TaxRealizationsModule,
  ],
  controllers: [TaxLotsController],
  providers: [TaxLotsService],
  exports: [TaxLotsService],
})
export class TaxLotsModule {}
