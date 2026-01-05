import { Controller, Get, Post, Body, Param, Delete, Put } from '@nestjs/common';
import { PrintersService } from './printers.service';
import { Printer } from './printer.entity';

@Controller('printers')
export class PrintersController {
    constructor(private readonly printersService: PrintersService) { }

    @Get()
    findAll(): Promise<Printer[]> {
        return this.printersService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string): Promise<Printer | null> {
        return this.printersService.findOne(+id);
    }

    @Post()
    create(@Body() printer: Printer): Promise<Printer> {
        return this.printersService.create(printer);
    }

    @Put(':id')
    update(@Param('id') id: string, @Body() printer: Partial<Printer>): Promise<Printer | null> {
        return this.printersService.update(+id, printer);
    }

    @Delete(':id')
    remove(@Param('id') id: string): Promise<void> {
        return this.printersService.remove(+id);
    }
}
