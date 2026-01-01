import { IsString, IsNumber, IsOptional, IsArray, ValidateNested, IsDateString } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateOrderItemDto {
  @IsNumber()
  menuItemId: number;

  @IsNumber()
  quantity: number;

  @IsNumber()
  priceAtTime: number;

  @IsOptional()
  @IsString()
  status?: string;
}

export class CreateOrderDto {
  @IsString()
  orderNumber: string;

  @IsOptional()
  @IsString()
  tableNumber?: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsNumber()
  waiterId?: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsNumber()
  totalAmount: number;

  @IsOptional()
  @IsNumber()
  taxAmount?: number;

  @IsOptional()
  @IsNumber()
  serviceAmount?: number;

  @IsOptional()
  @IsNumber()
  tipAmount?: number;

  @IsOptional()
  @IsString()
  paymentMethod?: string;
  
  @IsOptional()
  @IsString()
  taxNumber?: string;

  @IsOptional()
  @IsDateString()
  completedAt?: Date;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}
