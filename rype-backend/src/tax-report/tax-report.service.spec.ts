import { Test, TestingModule } from '@nestjs/testing';
import { TaxReportService } from './tax-report.service';

describe('TaxReportService', () => {
  let service: TaxReportService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TaxReportService],
    }).compile();

    service = module.get<TaxReportService>(TaxReportService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
