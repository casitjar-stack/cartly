import { BadRequestException } from '@nestjs/common';
import {
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from 'vitest';
import { ItemsController } from './items.controller';
import type { ItemsService } from './items.service';

describe('ItemsController', () => {
  let controller: ItemsController;

  const itemsService = {
    findAll: vi.fn(),
    create: vi.fn(),
    toggleBought: vi.fn(),
    clearBought: vi.fn(),
    remove: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();

    controller = new ItemsController(
      itemsService as unknown as ItemsService,
    );
  });

  it('rejects list requests without x-user-id', () => {
    expect(() => controller.findAll(undefined)).toThrow(
      BadRequestException,
    );
  });

  it('rejects create requests without x-user-id', () => {
    expect(() =>
      controller.create(undefined, {
        name: 'Milk',
        quantity: 1,
      }),
    ).toThrow(BadRequestException);
  });

  it('passes user ID and item ID when toggling an item', async () => {
    itemsService.toggleBought.mockResolvedValue({
      id: 'item-1',
      name: 'Milk',
      quantity: 1,
      bought: true,
    });

    await controller.toggleBought('user-1', 'item-1');

    expect(itemsService.toggleBought).toHaveBeenCalledWith(
      'user-1',
      'item-1',
    );
  });

  it('passes user ID when clearing bought items', async () => {
    itemsService.clearBought.mockResolvedValue({
      message: 'Bought items cleared successfully',
      deletedCount: 1,
    });

    await controller.clearBought('user-1');

    expect(itemsService.clearBought).toHaveBeenCalledWith(
      'user-1',
    );
  });

  it('passes user ID and item ID when deleting an item', async () => {
    itemsService.remove.mockResolvedValue({
      message: 'Item deleted successfully',
      id: 'item-1',
    });

    await controller.remove('user-1', 'item-1');

    expect(itemsService.remove).toHaveBeenCalledWith(
      'user-1',
      'item-1',
    );
  });
});