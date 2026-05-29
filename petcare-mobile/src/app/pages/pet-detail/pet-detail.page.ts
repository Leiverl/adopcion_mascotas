import { Component, OnInit, OnDestroy, inject, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ToastController } from '@ionic/angular';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { Mascota, MascotasService } from 'src/app/core/mascotas.service';
import { Subscription, switchMap } from 'rxjs';
import { FavoritosService } from 'src/app/core/favoritos.service';
import { ModalController } from '@ionic/angular'; // Importar
import { ImageViewerComponent } from 'src/app/components/image-viewer/image-viewer.component'; // Importar
import { register } from 'swiper/element/bundle';
register();

@Component({
  selector: 'app-pet-detail',
  templateUrl: './pet-detail.page.html',
  styleUrls: ['./pet-detail.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class PetDetailPage implements OnInit, OnDestroy {
  private activatedRoute = inject(ActivatedRoute);
  private mascotasService = inject(MascotasService);
  private favoritosService = inject(FavoritosService);
  private toastCtrl = inject(ToastController);
  private modalCtrl = inject(ModalController);
  public mascota?: Mascota;
  public isLoading = true;
  public isFavorite = false;
  public isAnimating = false; // Propiedad para la animación
  private favoriteIdsSub?: Subscription;

  ngOnInit() {
    this.activatedRoute.params.pipe(
      switchMap(({ id }) => this.mascotasService.getMascotaById(id))
    ).subscribe(data => {
      this.mascota = data;
      this.isLoading = false;

      this.favoriteIdsSub = this.favoritosService.getFavoriteIds().subscribe(ids => {
        this.isFavorite = ids.includes(this.mascota!._id);
      });
    });
  }

  toggleFavorite() {
    if (!this.mascota) return;

    this.isFavorite = !this.isFavorite;
    this.isAnimating = true; // Activa la animación

    const action = this.isFavorite 
      ? this.favoritosService.addFavorito(this.mascota._id)
      : this.favoritosService.removeFavorito(this.mascota._id);
    
    const message = this.isFavorite
      ? `${this.mascota.nombre} añadido a favoritos`
      : `${this.mascota.nombre} eliminado de favoritos`;

    action.subscribe({
      next: () => this.presentToast(message, 'success'),
      error: () => {
        this.isFavorite = !this.isFavorite; // Revertir si hay error
        this.presentToast('Ocurrió un error', 'danger');
      }
    });
    
    // Quita la clase de animación después de que termine
    setTimeout(() => this.isAnimating = false, 600);
  }
  
  async presentToast(message: string, color: 'success' | 'danger') {
    const toast = await this.toastCtrl.create({
      message: message,
      duration: 2000,
      color: color,
      position: 'top',
      icon: color === 'success' ? 'checkmark-circle-outline' : 'alert-circle-outline'
    });
    toast.present();
  }
  async openImageModal(index: number) {
    if (!this.mascota?.galeriaFotos) return;
    
    const modal = await this.modalCtrl.create({
      component: ImageViewerComponent,
      componentProps: {
        images: this.mascota.galeriaFotos,
        initialSlide: index
      }
    });
    await modal.present();
  }
  ngOnDestroy() {
    this.favoriteIdsSub?.unsubscribe();
  }
}