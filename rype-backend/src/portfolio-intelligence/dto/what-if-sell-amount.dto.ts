import { IsNumber, Min } from 'class-validator';

export class WhatIfSellAmountDto {
  @IsNumber()
  @Min(1)
  amount: number;
}
