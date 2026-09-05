import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Headers,
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
}