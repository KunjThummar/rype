import { Test, TestingModule } from '@nestjs/testing';
import { TaxDashboardController } from './tax-dashboard.controller';

describe('TaxDashboardController', () => {
  let controller: TaxDashboardController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TaxDashboardController],
    }).compile();

    controller = module.get<TaxDashboardController>(TaxDashboardController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
