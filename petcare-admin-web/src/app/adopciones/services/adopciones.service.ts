import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

// Crear interfaces para los datos
export interface SolicitudAdopcion {
  _id: string;
  estado: 'NUEVA' | 'EN_REVISION' | 'APROBADA' | 'RECHAZADA';
  mascota: {
    nombre: string;
    galeriaFotos: string[];
  } | null;
  adoptante: {
    nombre: string;
    correo: string;
  };
  conversacion?: { _id: string };
  isProcessing?: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class AdopcionesService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/solicitudes-adopcion`;

  getSolicitudes(): Observable<SolicitudAdopcion[]> {
    return this.http.get<SolicitudAdopcion[]>(this.baseUrl);
  }

  updateEstadoSolicitud(id: string, estado: string): Observable<SolicitudAdopcion> {
    return this.http.patch<SolicitudAdopcion>(`${this.baseUrl}/${id}/estado`, { estado });
  }
  deleteSolicitud(id: string): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
}