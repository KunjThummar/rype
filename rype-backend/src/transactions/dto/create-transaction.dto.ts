import { IsDateString, IsNumber, IsString, Min } from 'class-validator';

export class CreateTransactionDto {
  @IsString()
  assetType: string;

  @IsString()
  assetName: string;

  @IsString()
  symbol: string;

  @IsString()
  transactionType: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNumber()
  @Min(1)
  price: number;

  @IsDateString()
  transactionDate: Date;
}
