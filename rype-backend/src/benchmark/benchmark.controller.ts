import { Controller, Get } from '@nestjs/common';

import { BenchmarkService } from './benchmark.service';

@Controller('benchmark')
export class BenchmarkController {
  constructor(private benchmarkService: BenchmarkService) {}

  @Get()
  getBenchmarks() {
    return this.benchmarkService.getBenchmarks();
  }
}
