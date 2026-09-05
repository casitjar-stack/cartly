import { Injectable } from '@nestjs/common';
import { Timestamp } from 'firebase-admin/firestore';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateItemDto } from './dto/create-item.dto';

@Injectable()
export class ItemsService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async create(userId: string, dto: CreateItemDto) {
    const itemRef = this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('items')
      .doc();

    const createdAt = Timestamp.now();

    const item = {
      name: dto.name,
      quantity: dto.quantity,
      bought: false,
      createdAt,
    };

    await itemRef.set(item);

    return {
      id: itemRef.id,
      name: item.name,
      quantity: item.quantity,
      bought: item.bought,
      createdAt: createdAt.toDate().toISOString(),
    };
  }
}