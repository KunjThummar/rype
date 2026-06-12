import { Test, TestingModule } from '@nestjs/testing';
import { TaxRealizationsController } from './tax-realizations.controller';

describe('TaxRealizationsController', () => {
  let controller: TaxRealizationsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TaxRealizationsController],
    }).compile();

    controller = module.get<TaxRealizationsController>(
      TaxRealizationsController,
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
