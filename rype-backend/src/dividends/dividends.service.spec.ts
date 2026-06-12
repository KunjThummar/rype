import { Test, TestingModule } from '@nestjs/testing';
import { DividendsService } from './dividends.service';

describe('DividendsService', () => {
  let service: DividendsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DividendsService],
    }).compile();

    service = module.get<DividendsService>(DividendsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
