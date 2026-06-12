import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Dividend, DividendSchema } from './schemas/dividend.schema';

import { DividendsController } from './dividends.controller';
import { DividendsService } from './dividends.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Dividend.name,
        schema: DividendSchema,
      },
    ]),
  ],
  controllers: [DividendsController],
  providers: [DividendsService],
})
export class DividendsModule {}
