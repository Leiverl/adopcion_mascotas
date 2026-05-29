import { Component, CUSTOM_ELEMENTS_SCHEMA, inject, ViewChild, ElementRef, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ModalController, ViewDidLeave, ViewWillEnter } from '@ionic/angular';
import { Mascota, MascotasService } from 'src/app/core/mascotas.service';
import { Router, RouterModule } from '@angular/router';
import { FilterModalComponent } from 'src/app/components/filter-modal/filter-modal.component';
import { FavoritosService } from 'src/app/core/favoritos.service';
import { UiService } from 'src/app/core/ui.service';
import { Subscription } from 'rxjs';

import { register } from 'swiper/element/bundle';
register();

@Component({
  selector: 'app-discover',
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule],
  templateUrl: './discover.page.html',
  styleUrls: ['./discover.page.scss'],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class DiscoverPage implements ViewWillEnter, OnDestroy, ViewDidLeave {
  @ViewChild('swiper') swiperRef: ElementRef | undefined;

  private mascotasService = inject(MascotasService);
  private modalCtrl = inject(ModalController);
  private favoritosService = inject(FavoritosService);
  private uiService = inject(UiService);
  private router = inject(Router);

  public mascotas: Mascota[] = [];
  public isLoading = true;
  private currentFilters: any = {};
  
  private favoriteIds: string[] = [];
  private favoriteIdsSub?: Subscription;

  ionViewWillEnter() {
    this.loadMascotas();
    this.favoriteIdsSub = this.favoritosService.getFavoriteIds().subscribe(ids => {
      this.favoriteIds = ids;
    });
  }

  ionViewDidLeave() {
    const swiperEl = this.swiperRef?.nativeElement;
    if (swiperEl && swiperEl.swiper && typeof swiperEl.swiper.destroy === 'function') {
      swiperEl.swiper.destroy(true, true);
    }
  }

  loadMascotas(filters: any = {}) {
    this.isLoading = true;
    this.currentFilters = filters;
    this.mascotasService.getMascotas(this.currentFilters).subscribe(data => {
      this.mascotas = data;
      this.isLoading = false;
    });
  }

  async openFilterModal() {
    const modal = await this.modalCtrl.create({
      component: FilterModalComponent,
      componentProps: { 'currentFilters': this.currentFilters }
    });
    await modal.present();

    const { data } = await modal.onWillDismiss();
    if (data) this.loadMascotas(data);
  }

  private getCurrentPet(): Mascota | null {
    const swiper = this.swiperRef?.nativeElement.swiper;
    if (swiper && this.mascotas.length > 0 && swiper.activeIndex < this.mascotas.length) {
      return this.mascotas[swiper.activeIndex];
    }
    return null;
  }

  private slideNext() {
    this.swiperRef?.nativeElement.swiper.slideNext();
  }

  handleAction(action: 'reject' | 'details' | 'favorite') {
    const pet = this.getCurrentPet();
    if (!pet) return;

    switch (action) {
      case 'reject':
        this.slideNext();
        break;
      
      case 'details':
        this.router.navigate(['/tabs/discover', pet._id]);
        break;
      
      case 'favorite':
        const isCurrentlyFavorite = this.favoriteIds.includes(pet._id);
        
        if (isCurrentlyFavorite) {
          this.favoritosService.removeFavorito(pet._id).subscribe({
            next: () => this.uiService.showSuccess(`${pet.nombre} eliminado de favoritos.`),
            error: (err: any) => this.uiService.showError(err.error.message || 'Error al eliminar favorito.')
          });
        } else {
          this.favoritosService.addFavorito(pet._id).subscribe({
            next: () => {
              this.uiService.showSuccess(`${pet.nombre} añadido a favoritos!`);
              this.triggerHeartAnimation();
            },
            error: (err: any) => this.uiService.showError(err.error.message || 'Error al añadir favorito.')
          });
        }
        this.slideNext();
        break;
    }
  }

  // --- TU CÓDIGO DE ANIMACIÓN INTEGRADO ---
  triggerHeartAnimation() { 
    const numberOfHearts = 25; 
  
    for (let i = 0; i < numberOfHearts; i++) { 
      const heart = document.createElement('img'); 
      heart.src = 'assets/heart.png'; // Ruta relativa desde src 
      heart.style.position = 'fixed'; 
      heart.style.width = `${Math.random() * 30 + 50}px`; 
      heart.style.height = 'auto'; 
      heart.style.zIndex = '9999'; 
      heart.style.top = '50%'; 
      heart.style.left = '50%'; 
      heart.style.pointerEvents = 'none'; 
      heart.style.transform = `translate(-50%, -50%) scale(${Math.random() * 0.5 + 0.8})`; 
      heart.style.opacity = '1'; 
      heart.style.transition = 'all 2s ease-out'; 
  
      document.body.appendChild(heart); 
  
      // Movimiento aleatorio hacia arriba 
      setTimeout(() => { 
        const x = (Math.random() - 0.5) * 300; 
        const y = Math.random() * -300 - 100; 
  
        heart.style.transform = `translate(${x}px, ${y}px) scale(0.3)`; 
        heart.style.opacity = '0'; 
      }, 100); 
  
      // Eliminar después de la animación 
      setTimeout(() => { 
        if (heart && heart.parentNode) { 
          heart.parentNode.removeChild(heart); 
        } 
      }, 2100); 
    }
  }

  ngOnDestroy() {
    this.favoriteIdsSub?.unsubscribe();
  }
}