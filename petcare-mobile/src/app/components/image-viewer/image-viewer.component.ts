import { Component, Input, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ModalController } from '@ionic/angular';

@Component({
  selector: 'app-image-viewer',
  standalone: true,
  imports: [IonicModule, CommonModule],
  templateUrl: './image-viewer.component.html',
  styleUrls: ['./image-viewer.component.scss'],
  schemas: [CUSTOM_ELEMENTS_SCHEMA] // Para Swiper
})
export class ImageViewerComponent {
  @Input() images: string[] = [];
  @Input() initialSlide: number = 0;

  constructor(private modalCtrl: ModalController) {}

  close() {
    this.modalCtrl.dismiss();
  }
}