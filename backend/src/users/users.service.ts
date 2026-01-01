import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { EventsGateway } from '../events/events.gateway';

@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private eventsGateway: EventsGateway,
    ) { }

    async findAll(): Promise<User[]> {
        return this.usersRepository.find();
    }

    async findOne(id: number): Promise<User> {
        const user = await this.usersRepository.findOneBy({ id });
        if (!user) {
            throw new NotFoundException(`User #${id} not found`);
        }
        return user;
    }

    async create(userData: Partial<User>): Promise<User> {
        const newUser = this.usersRepository.create(userData);
        const savedUser = await this.usersRepository.save(newUser);
        this.eventsGateway.emitUserUpdate(savedUser);
        return savedUser;
    }

    async update(id: number, userData: Partial<User>): Promise<User> {
        await this.usersRepository.update(id, userData);
        const updatedUser = await this.findOne(id);
        this.eventsGateway.emitUserUpdate(updatedUser);
        return updatedUser;
    }

    async remove(id: number): Promise<void> {
        const user = await this.findOne(id);
        user.status = 'deleted'; // Soft delete or handle as needed, for sync matching logic usually 'deleted' status is safer if we want to propogate
        // OR actually delete:
        // await this.usersRepository.delete(id);
        // For sync systems, it's often better to mark as deleted to propogate the deletion. 
        // Let's stick to status update for now or actual delete if the client handles it.
        // Given the simple sync implementation likely overwrites, let's just delete for now and assume full sync handles re-population, 
        // OR better, we emit a deleted event. 
        // For simplicity with the current 'upsert' logic in frontend, let's just mark status as 'inactive' or 'deleted'.
        await this.usersRepository.update(id, { status: 'deleted' });
        const deletedUser = await this.findOne(id);
        this.eventsGateway.emitUserUpdate(deletedUser);
    }
}
