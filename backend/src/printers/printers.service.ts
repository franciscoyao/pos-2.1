import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Printer } from './printer.entity';

@Injectable()
export class PrintersService {
    constructor(
        @InjectRepository(Printer)
        private printersRepository: Repository<Printer>,
    ) { }

    findAll(): Promise<Printer[]> {
        return this.printersRepository.find();
    }

    findOne(id: number): Promise<Printer | null> {
        return this.printersRepository.findOneBy({ id });
    }

    create(printer: Printer): Promise<Printer> {
        return this.printersRepository.save(printer);
    }

    async remove(id: number): Promise<void> {
        await this.printersRepository.delete(id);
    }

    async update(id: number, printer: Partial<Printer>): Promise<Printer | null> {
        await this.printersRepository.update(id, printer);
        return this.printersRepository.findOneBy({ id });
    }
}
