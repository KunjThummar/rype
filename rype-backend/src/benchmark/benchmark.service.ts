import { Injectable } from '@nestjs/common';

@Injectable()
export class BenchmarkService {
  async getBenchmarks() {
    return {
      nifty50: {
        name: 'NIFTY 50',
        yearlyReturn: 12.5,
      },

      sensex: {
        name: 'SENSEX',
        yearlyReturn: 10.8,
      },
    };
  }
}
