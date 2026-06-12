import { Test, TestingModule } from '@nestjs/testing';
import { TaxLotsController } from './tax-lots.controller';

describe('TaxLotsController', () => {
  let controller: TaxLotsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TaxLotsController],
    }).compile();

    controller = module.get<TaxLotsController>(TaxLotsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
