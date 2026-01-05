import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity()
export class User {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ name: 'full_name', nullable: true })
    fullName: string;

    @Column({ unique: true, nullable: true })
    username: string;

    @Column({ nullable: true })
    pin: string; // 4-digit PIN

    @Column()
    role: string; // "admin", "waiter", "kitchen", "bar", "kiosk"

    @Column({ default: 'active' })
    status: string;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;
}
