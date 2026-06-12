import { Test, TestingModule } from '@nestjs/testing';
import { TaxLotsService } from './tax-lots.service';

describe('TaxLotsService', () => {
  let service: TaxLotsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TaxLotsService],
    }).compile();

    service = module.get<TaxLotsService>(TaxLotsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
