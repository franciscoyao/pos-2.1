import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Setting } from './setting.entity';

@Injectable()
export class SettingsService {
    constructor(
        @InjectRepository(Setting)
        private settingsRepository: Repository<Setting>,
    ) { }

    findAll(): Promise<Setting[]> {
        return this.settingsRepository.find();
    }

    findOne(id: number): Promise<Setting | null> {
        return this.settingsRepository.findOneBy({ id });
    }

    create(setting: Setting): Promise<Setting> {
        return this.settingsRepository.save(setting);
    }

    async remove(id: number): Promise<void> {
        await this.settingsRepository.delete(id);
    }

    async update(id: number, setting: Partial<Setting>): Promise<Setting | null> {
        await this.settingsRepository.update(id, setting);
        return this.settingsRepository.findOneBy({ id });
    }
}
