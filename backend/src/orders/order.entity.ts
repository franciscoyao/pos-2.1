import { Entity, Column, PrimaryGeneratedColumn, OneToMany, CreateDateColumn } from 'typeorm';
import { OrderItem } from './order-item.entity';

@Entity('orders')
export class Order {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ name: 'order_number', unique: true })
    orderNumber: string;

    @Column({ name: 'table_number', nullable: true })
    tableNumber: string;

    @Column({ default: 'dine-in' })
    type: string;

    @Column({ name: 'waiter_id', nullable: true })
    waiterId: number;

    @Column({ default: 'pending' })
    status: string;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @Column('float', { name: 'total_amount', default: 0.0 })
    totalAmount: number;

    @Column('float', { name: 'tax_amount', default: 0.0 })
    taxAmount: number;

    @Column('float', { name: 'service_amount', default: 0.0 })
    serviceAmount: number;

    @Column({ name: 'payment_method', nullable: true })
    paymentMethod: string;

    @Column('float', { name: 'tip_amount', default: 0.0 })
    tipAmount: number;

    @Column({ name: 'tax_number', type: 'varchar', nullable: true })
    taxNumber: string | null;

    @Column({ name: 'completed_at', type: 'timestamp', nullable: true })
    completedAt: Date;

    @OneToMany(() => OrderItem, (orderItem) => orderItem.order, { cascade: true })
    items: OrderItem[];
}
