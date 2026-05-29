import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Mascota } from './mascotas.service';

export interface Solicitud {
  _id: string;
  mascota: Mascota;
  estado: 'NUEVA' | 'EN_REVISION' | 'APROBADA' | 'RECHAZADA';
  createdAt: string;
  urlPdfCertificado?: string;
}

@Injectable({
  providedIn: 'root'
})
export class SolicitudesService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/solicitudes-adopcion`;

  enviarSolicitud(solicitudData: { mascota: string, respuestasFormulario: any }): Observable<any> {
    return this.http.post(this.apiUrl, solicitudData);
  }

  getMisSolicitudes(): Observable<Solicitud[]> {
    return this.http.get<Solicitud[]>(`${this.apiUrl}/mis-solicitudes`);
  }
  getSolicitudById(id: string): Observable<Solicitud> {
    return this.http.get<Solicitud>(`${this.apiUrl}/${id}`);
  }
}