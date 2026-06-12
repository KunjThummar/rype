import { Test, TestingModule } from '@nestjs/testing';
import { TaxDashboardService } from './tax-dashboard.service';

describe('TaxDashboardService', () => {
  let service: TaxDashboardService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TaxDashboardService],
    }).compile();

    service = module.get<TaxDashboardService>(TaxDashboardService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
