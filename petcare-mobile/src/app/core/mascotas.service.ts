import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface Mascota {
  _id: string;
  nombre: string;
  especie: string;
  raza: string;
  edad: number;
  sexo: 'MACHO' | 'HEMBRA';
  tamano: string;
  descripcion: string;
  estado: 'DISPONIBLE' | 'EN_PROCESO' | 'ADOPTADA'; // <-- AÑADIR ESTA LÍNEA
  galeriaFotos: string[];
  refugio: {
    _id: string;
    nombre: string;
  }
}

@Injectable({
  providedIn: 'root'
})
export class MascotasService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/mascotas`;

  getMascotas(filters: any = {}): Observable<Mascota[]> {
    let params = new HttpParams();
    Object.keys(filters).forEach(key => {
      if (filters[key]) {
        params = params.append(key, filters[key]);
      }
    });
    return this.http.get<Mascota[]>(this.apiUrl, { params });
  }

  getMascotaById(id: string): Observable<Mascota> {
    return this.http.get<Mascota>(`${this.apiUrl}/${id}`);
  }
}