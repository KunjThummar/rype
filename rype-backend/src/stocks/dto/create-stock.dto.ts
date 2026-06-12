import { IsNumber, IsString, Min } from 'class-validator';

export class CreateStockDto {
  @IsString()
  stockName: string;

  @IsString()
  symbol: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNumber()
  @Min(1)
  buyPrice: number;

  @IsNumber()
  @Min(1)
  currentPrice: number;
}
