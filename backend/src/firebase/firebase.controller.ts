import { Controller, Get } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

@Controller('firebase')
export class FirebaseController {
  constructor(private readonly firebaseService: FirebaseService) {}

  @Get('health')
  async health() {
    const collections = await this.firebaseService.firestore.listCollections();

    return {
      status: 'ok',
      firestore: 'connected',
      collectionCount: collections.length,
    };
  }
}