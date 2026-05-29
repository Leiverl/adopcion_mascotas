import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Refugio {
  _id: string;
  nombre: string;
  logo: string;
  direccion: string;
  infoContacto: string;
  historia: string;
  propietario: string | { _id: string, nombre: string }; // Puede ser ID o un objeto poblado
}

@Injectable({
  providedIn: 'root'
})
export class RefugiosService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/refugios`;

  getRefugios(): Observable<Refugio[]> {
    return this.http.get<Refugio[]>(this.baseUrl);
  }

  // --- MÉTODO AÑADIDO ---
  getRefugioById(id: string): Observable<Refugio> {
    return this.http.get<Refugio>(`${this.baseUrl}/${id}`);
  }

  getMyProfile(): Observable<Refugio> {
    return this.http.get<Refugio>(`${this.baseUrl}/mi-perfil`);
  }

  // --- MÉTODO RENOMBRADO (de updateProfile a updateRefugio) ---
  updateRefugio(id: string, data: any, file?: File): Observable<Refugio> {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    if (file) {
      formData.append('logo', file);
    }
    return this.http.patch<Refugio>(`${this.baseUrl}/${id}`, formData);
  }

  addRefugio(data: any, file: File): Observable<Refugio> {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    formData.append('logo', file);
    return this.http.post<Refugio>(this.baseUrl, formData);
  }

  deleteRefugio(id: string): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
}