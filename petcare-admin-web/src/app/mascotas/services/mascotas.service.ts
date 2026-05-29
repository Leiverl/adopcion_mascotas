import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Refugio } from '../../refugios/services/refugios.service';
export interface Mascota {
  _id: string;
  nombre: string;
  especie: string;
  raza: string;
  edad: number;
  sexo: 'MACHO' | 'HEMBRA';
  tamano: string;
  estado: 'DISPONIBLE' | 'EN_PROCESO' | 'ADOPTADA';
  descripcion: string;
  galeriaFotos: string[];
  refugio: Refugio;
}

@Injectable({
  providedIn: 'root'
})
export class MascotasService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/mascotas`;

  getMascotas(): Observable<Mascota[]> {
    return this.http.get<Mascota[]>(this.baseUrl);
  }

  getMascotaById(id: string): Observable<Mascota> {
    return this.http.get<Mascota>(`${this.baseUrl}/${id}`);
  }

  addMascota(data: any, files: File[]): Observable<Mascota> {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    files.forEach(file => formData.append('galeriaFotos', file));
    return this.http.post<Mascota>(this.baseUrl, formData);
  }

  updateMascota(id: string, data: Partial<Mascota>, files?: File[]): Observable<Mascota> {
    const formData = new FormData();
    Object.keys(data).forEach(key => {
        const value = (data as any)[key];
        if (value !== null && value !== undefined) {
            formData.append(key, value);
        }
    });

    if (files && files.length > 0) {
        files.forEach(file => formData.append('galeriaFotos', file));
    }

    return this.http.patch<Mascota>(`${this.baseUrl}/${id}`, formData);
  }

  deleteMascota(id: string): Observable<{ message: string }> {
    return this.http.delete<{ message: string }>(`${this.baseUrl}/${id}`);
  }
}