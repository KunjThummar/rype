import { IsNumber, Min } from 'class-validator';

export class CreatePortfolioDto {
  @IsNumber()
  @Min(0)
  totalInvestment: number;

  @IsNumber()
  @Min(0)
  currentValue: number;

  @IsNumber()
  totalProfitLoss: number;
}
