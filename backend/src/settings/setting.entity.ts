import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('settings')
export class Setting {
    @PrimaryGeneratedColumn()
    id: number;

    @Column('float', { name: 'tax_rate', default: 0.0 })
    taxRate: number;

    @Column('float', { name: 'service_rate', default: 0.0 })
    serviceRate: number;

    @Column({ name: 'currency_symbol', default: '$' })
    currencySymbol: string;

    @Column({ name: 'kiosk_mode', default: false })
    kioskMode: boolean;

    @Column({ name: 'order_delay_threshold', default: 15 })
    orderDelayThreshold: number;
}
