import { Controller, Get, Param } from '@nestjs/common';

import { MarketDataService } from './market-data.service';

@Controller('market-data')
export class MarketDataController {
  constructor(private marketDataService: MarketDataService) {}

  @Get('stock/:symbol')
  getStockPrice(
    @Param('symbol')
    symbol: string,
  ) {
    return this.marketDataService.getStockPrice(symbol);
  }

  @Get('nav/:amfiCode')
  getNav(
    @Param('amfiCode')
    amfiCode: string,
  ) {
    return this.marketDataService.getNav(amfiCode);
  }
}
