import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { TaxLot, TaxLotSchema } from '../tax-lots/schemas/tax-lot.schema';

import { WhatIfController } from './what-if.controller';
import { WhatIfService } from './what-if.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: TaxLot.name,
        schema: TaxLotSchema,
      },
    ]),
  ],
  controllers: [WhatIfController],
  providers: [WhatIfService],
})
export class WhatIfModule {}
