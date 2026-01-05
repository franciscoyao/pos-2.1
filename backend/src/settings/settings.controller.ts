import { Controller, Get, Post, Body, Param, Delete, Put } from '@nestjs/common';
import { SettingsService } from './settings.service';
import { Setting } from './setting.entity';

@Controller('settings')
export class SettingsController {
    constructor(private readonly settingsService: SettingsService) { }

    @Get()
    findAll(): Promise<Setting[]> {
        return this.settingsService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string): Promise<Setting | null> {
        return this.settingsService.findOne(+id);
    }

    @Post()
    create(@Body() setting: Setting): Promise<Setting> {
        return this.settingsService.create(setting);
    }

    @Put(':id')
    update(@Param('id') id: string, @Body() setting: Partial<Setting>): Promise<Setting | null> {
        return this.settingsService.update(+id, setting);
    }

    @Delete(':id')
    remove(@Param('id') id: string): Promise<void> {
        return this.settingsService.remove(+id);
    }
}
