import { Injectable } from '@nestjs/common';

@Injectable()
export class StockPriceProvider {
  async getPrice(symbol: string) {
    const mockPrices = {
      TCS: 4200,
      INFY: 1800,
      HDFCBANK: 1750,
      RELIANCE: 2950,
    };

    return mockPrices[symbol] || 100;
  }
}
