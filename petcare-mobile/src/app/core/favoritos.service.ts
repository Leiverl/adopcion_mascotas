import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Mascota } from './mascotas.service';

export interface Favorito {
  _id: string;
  mascota: Mascota;
}

@Injectable({
  providedIn: 'root'
})
export class FavoritosService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/favoritos`;

  // Mantiene una lista de los IDs de las mascotas favoritas
  private favoriteIds$ = new BehaviorSubject<string[]>([]);

  // Expone la lista como un Observable para que los componentes se suscriban
  getFavoriteIds(): Observable<string[]> {
    return this.favoriteIds$.asObservable();
  }
  
  // Carga los favoritos desde la API y actualiza el estado
  loadMyFavorites(): void {
    this.http.get<Favorito[]>(`${this.apiUrl}/mis-favoritos`).subscribe(favoritos => {
      const ids = favoritos.map(fav => fav.mascota._id);
      this.favoriteIds$.next(ids);
    });
  }

  addFavorito(mascotaId: string): Observable<any> {
    return this.http.post(this.apiUrl, { mascotaId }).pipe(
      tap(() => {
        const currentIds = this.favoriteIds$.getValue();
        this.favoriteIds$.next([...currentIds, mascotaId]);
      })
    );
  }

  removeFavorito(mascotaId: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${mascotaId}`).pipe(
      tap(() => {
        const currentIds = this.favoriteIds$.getValue();
        this.favoriteIds$.next(currentIds.filter(id => id !== mascotaId));
      })
    );
  }
  getMisFavoritos(): Observable<Favorito[]> {
    return this.http.get<Favorito[]>(`${this.apiUrl}/mis-favoritos`);
  }
}