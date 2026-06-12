import { Test, TestingModule } from '@nestjs/testing';
import { TaxRealizationsService } from './tax-realizations.service';

describe('TaxRealizationsService', () => {
  let service: TaxRealizationsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TaxRealizationsService],
    }).compile();

    service = module.get<TaxRealizationsService>(TaxRealizationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
