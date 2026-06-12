import { Test, TestingModule } from '@nestjs/testing';
import { PortfolioCalculatorService } from './portfolio-calculator.service';

describe('PortfolioCalculatorService', () => {
  let service: PortfolioCalculatorService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PortfolioCalculatorService],
    }).compile();

    service = module.get<PortfolioCalculatorService>(
      PortfolioCalculatorService,
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
