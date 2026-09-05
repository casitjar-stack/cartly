import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { CreateItemDto } from './dto/create-item.dto';
import { ItemsService } from './items.service';

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Get()
  findAll(@Headers('x-user-id') userId: string | undefined) {
    if (!userId?.trim()) {
      throw new BadRequestException('x-user-id header is required');
    }

    return this.itemsService.findAll(userId.trim());
  }

  @Post()
  create(
    @Headers('x-user-id') userId: string | undefined,
    @Body() dto: CreateItemDto,
  ) {
    if (!userId?.trim()) {
      throw new BadRequestException('x-user-id header is required');
    }

    return this.itemsService.create(userId.trim(), dto);
  }

  @Patch(':id/toggle')
  toggleBought(
    @Headers('x-user-id') userId: string | undefined,
    @Param('id') itemId: string,
  ) {
    if (!userId?.trim()) {
      throw new BadRequestException('x-user-id header is required');
    }

    return this.itemsService.toggleBought(userId.trim(), itemId);
  }

  @Delete('bought/clear')
  clearBought(@Headers('x-user-id') userId: string | undefined) {
    if (!userId?.trim()) {
      throw new BadRequestException('x-user-id header is required');
    }

    return this.itemsService.clearBought(userId.trim());
  }

  @Delete(':id')
  remove(
    @Headers('x-user-id') userId: string | undefined,
    @Param('id') itemId: string,
  ) {
    if (!userId?.trim()) {
      throw new BadRequestException('x-user-id header is required');
    }

    return this.itemsService.remove(userId.trim(), itemId);
  }
}