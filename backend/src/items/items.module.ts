import { Module } from '@nestjs/common';
import { FirebaseModule } from '../firebase/firebase.module';
import { ItemsController } from './items.controller';
import { ItemsService } from './items.service';

@Module({
  imports: [FirebaseModule],
  controllers: [ItemsController],
  providers: [ItemsService],
})
export class ItemsModule {}