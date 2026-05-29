import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ViewWillEnter } from '@ionic/angular';
import { Favorito, FavoritosService } from 'src/app/core/favoritos.service';
import { RouterModule } from '@angular/router';
import { UiService } from 'src/app/core/ui.service'; // <-- IMPORTAR

@Component({
  selector: 'app-favorites',
  templateUrl: './favorites.page.html',
  styleUrls: ['./favorites.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule]
})
export class FavoritesPage implements ViewWillEnter {
  private favoritosService = inject(FavoritosService);
  private uiService = inject(UiService); // <-- INYECTAR
  
  public favoritos: Favorito[] = [];
  public isLoading = true;

  ionViewWillEnter() {
    this.isLoading = true;
    this.favoritosService.getMisFavoritos().subscribe(data => {
      this.favoritos = data;
      this.isLoading = false;
    });
  }

  // --- NUEVO MÉTODO ---
  onRemoveFavorite(favorito: Favorito, event: Event) {
    event.stopPropagation(); // Evita que se active la navegación al detalle
    event.preventDefault();

    this.favoritosService.removeFavorito(favorito.mascota._id).subscribe(() => {
      // Elimina el favorito de la lista local para una actualización instantánea
      this.favoritos = this.favoritos.filter(f => f._id !== favorito._id);
      this.uiService.showSuccess(`${favorito.mascota.nombre} eliminado de favoritos.`);
    });
  }
}