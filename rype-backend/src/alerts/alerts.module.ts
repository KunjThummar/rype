import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Alert, AlertSchema } from './schemas/alert.schema';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import { AlertsController } from './alerts.controller';
import { AlertsService } from './alerts.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Alert.name,
        schema: AlertSchema,
      },
      {
        name: Stock.name,
        schema: StockSchema,
      },
    ]),
  ],
  controllers: [AlertsController],
  providers: [AlertsService],
})
export class AlertsModule {}
