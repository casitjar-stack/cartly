import { Injectable, NotFoundException } from '@nestjs/common';
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

  async findAll(userId: string) {
    const snapshot = await this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('items')
      .orderBy('bought', 'asc')
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => {
      const data = doc.data();

      return {
        id: doc.id,
        name: data.name,
        quantity: data.quantity,
        bought: data.bought,
        createdAt: data.createdAt.toDate().toISOString(),
      };
    });
  }

  async toggleBought(userId: string, itemId: string) {
    const itemRef = this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('items')
      .doc(itemId);

    const snapshot = await itemRef.get();

    if (!snapshot.exists) {
      throw new NotFoundException('Item not found');
    }

    const data = snapshot.data();
    const bought = !Boolean(data?.bought);

    await itemRef.update({
      bought,
    });

    return {
      id: snapshot.id,
      name: data?.name,
      quantity: data?.quantity,
      bought,
      createdAt: data?.createdAt.toDate().toISOString(),
    };
  }

  async clearBought(userId: string) {
    const snapshot = await this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('items')
      .where('bought', '==', true)
      .get();

    if (snapshot.empty) {
      return {
        message: 'No bought items to clear',
        deletedCount: 0,
      };
    }

    const batch = this.firebaseService.firestore.batch();

    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    return {
      message: 'Bought items cleared successfully',
      deletedCount: snapshot.size,
    };
  }

  async remove(userId: string, itemId: string) {
    const itemRef = this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('items')
      .doc(itemId);

    const snapshot = await itemRef.get();

    if (!snapshot.exists) {
      throw new NotFoundException('Item not found');
    }

    await itemRef.delete();

    return {
      message: 'Item deleted successfully',
      id: itemId,
    };
  }
}