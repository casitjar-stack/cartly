import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { Firestore, getFirestore } from 'firebase-admin/firestore';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class FirebaseService {
  private readonly db: Firestore;

  constructor(private readonly configService: ConfigService) {
    const serviceAccountPath = this.configService.get<string>(
      'FIREBASE_SERVICE_ACCOUNT_PATH',
    );

    if (!serviceAccountPath) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH is not configured');
    }

    const absolutePath = path.resolve(process.cwd(), serviceAccountPath);

    const serviceAccount = JSON.parse(
      fs.readFileSync(absolutePath, 'utf8'),
    );

    const app =
      getApps().length > 0
        ? getApps()[0]
        : initializeApp({
            credential: cert(serviceAccount),
          });

    this.db = getFirestore(app);
  }

  get firestore(): Firestore {
    return this.db;
  }
}