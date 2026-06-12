import { Test, TestingModule } from '@nestjs/testing';
import { MutualFundsService } from './mutual-funds.service';

describe('MutualFundsService', () => {
  let service: MutualFundsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [MutualFundsService],
    }).compile();

    service = module.get<MutualFundsService>(MutualFundsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
