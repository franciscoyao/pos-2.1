import { Controller, Get, Post, Body, Put, Param } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { Order } from './order.entity';
import { CreateOrderDto } from './dto/create-order.dto';

@Controller('orders')
export class OrdersController {
    constructor(private readonly ordersService: OrdersService) { }

    @Get('sync')
    getSyncOrders(): Promise<Order[]> {
        return this.ordersService.getSyncOrders();
    }

    @Get()
    findAll(): Promise<Order[]> {
        return this.ordersService.findAll();
    }

    @Post()
    create(@Body() createOrderDto: CreateOrderDto): Promise<Order> {
        return this.ordersService.create(createOrderDto as any);
    }

    @Put(':id')
    update(@Param('id') id: string, @Body() order: Partial<Order>): Promise<Order> {
        return this.ordersService.update(+id, order);
    }
}
