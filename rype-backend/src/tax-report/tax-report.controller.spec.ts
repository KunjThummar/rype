import { Test, TestingModule } from '@nestjs/testing';
import { TaxReportController } from './tax-report.controller';

describe('TaxReportController', () => {
  let controller: TaxReportController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TaxReportController],
    }).compile();

    controller = module.get<TaxReportController>(TaxReportController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
