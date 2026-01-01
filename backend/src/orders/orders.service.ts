import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThan } from 'typeorm';
import { Order } from './order.entity';
import { EventsGateway } from '../events/events.gateway';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    private eventsGateway: EventsGateway,
  ) { }

  // Get all orders
  findAll(): Promise<Order[]> {
    return this.ordersRepository.find({
      relations: ['items', 'items.menuItem'],
      order: { createdAt: 'DESC' },
    });
  }

  // Get active orders (pending, preparing, ready)
  async getActiveOrders(): Promise<Order[]> {
    return this.ordersRepository.find({
      where: [
        { status: 'pending' },
        { status: 'preparing' },
        { status: 'ready' },
      ],
      relations: ['items', 'items.menuItem'],
      order: { createdAt: 'DESC' },
    });
  }

  // Get orders by date range
  async getOrdersByDateRange(startDate: Date, endDate: Date): Promise<Order[]> {
    return this.ordersRepository.find({
      where: {
        createdAt: Between(startDate, endDate),
      },
      relations: ['items', 'items.menuItem'],
      order: { createdAt: 'DESC' },
    });
  }

  // Get orders for sync (Active + Recent History)
  async getSyncOrders(): Promise<Order[]> {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    return this.ordersRepository.find({
      where: [
        // Active orders (not completed or cancelled)
        { status: 'pending' },
        { status: 'sent' },
        { status: 'accepted' },
        { status: 'cooking' },
        { status: 'ready' },
        { status: 'served' },
        { status: 'paid' }, // 'paid' is still open until table is cleared/completed
        // Recent history
        { status: 'completed', createdAt: MoreThan(sevenDaysAgo) },
        { status: 'cancelled', createdAt: MoreThan(sevenDaysAgo) },
      ],
      relations: ['items', 'items.menuItem'],
      order: { createdAt: 'DESC' },
    });
  }

  // Get order by ID
  async findOne(id: number): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id },
      relations: ['items', 'items.menuItem'],
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${id} not found`);
    }

    return order;
  }

  // Get orders by table
  async getOrdersByTable(tableNumber: string): Promise<Order[]> {
    return this.ordersRepository.find({
      where: { tableNumber },
      relations: ['items', 'items.menuItem'],
      order: { createdAt: 'DESC' },
    });
  }

  // Create new order
  async create(orderData: Partial<Order>): Promise<Order> {
    const newOrder = this.ordersRepository.create(orderData);
    const savedOrder = await this.ordersRepository.save(newOrder);

    // Fetch with relations
    const orderWithRelations = await this.findOne(savedOrder.id);

    // Emit WebSocket event
    this.eventsGateway.emitNewOrder(orderWithRelations);

    return orderWithRelations;
  }

  // Update order
  async update(id: number, orderData: Partial<Order>): Promise<Order> {
    await this.ordersRepository.update(id, orderData);
    const updatedOrder = await this.findOne(id);

    // Emit WebSocket event
    this.eventsGateway.emitOrderUpdate(updatedOrder);

    return updatedOrder;
  }

  // Update order status
  async updateStatus(id: number, status: string): Promise<Order> {
    const order = await this.findOne(id);

    if (status === 'completed') {
      order.completedAt = new Date();
    }

    order.status = status;
    const updatedOrder = await this.ordersRepository.save(order);

    // Emit WebSocket event
    this.eventsGateway.emitOrderUpdate(updatedOrder);

    return updatedOrder;
  }

  // Complete order with payment
  async completeOrder(id: number, paymentData: {
    paymentMethod: string;
    tipAmount?: number;
    taxNumber?: string;
  }): Promise<Order> {
    const order = await this.findOne(id);

    order.status = 'completed';
    order.completedAt = new Date();
    order.paymentMethod = paymentData.paymentMethod;
    order.tipAmount = paymentData.tipAmount || 0;
    order.taxNumber = paymentData.taxNumber || null;

    const completedOrder = await this.ordersRepository.save(order);

    // Emit WebSocket event
    this.eventsGateway.emitOrderUpdate(completedOrder);

    return completedOrder;
  }

  // Delete order
  async remove(id: number): Promise<void> {
    const order = await this.findOne(id);
    await this.ordersRepository.remove(order);
  }

  // Get sales statistics
  async getSalesStats(startDate: Date, endDate: Date) {
    const orders = await this.getOrdersByDateRange(startDate, endDate);

    const completed = orders.filter(o => o.status === 'completed');

    const totalSales = completed.reduce((sum, o) => sum + o.totalAmount, 0);
    const totalTax = completed.reduce((sum, o) => sum + o.taxAmount, 0);
    const totalService = completed.reduce((sum, o) => sum + o.serviceAmount, 0);
    const totalTips = completed.reduce((sum, o) => sum + o.tipAmount, 0);

    return {
      totalOrders: completed.length,
      totalSales,
      totalTax,
      totalService,
      totalTips,
      averageOrderValue: completed.length > 0 ? totalSales / completed.length : 0,
    };
  }
}
