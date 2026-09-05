import {
  BadRequestException,
  Body,
  Controller,
  Headers,
  Post,
} from '@nestjs/common';
import { CreateItemDto } from './dto/create-item.dto';
import { ItemsService } from './items.service';

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

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