import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Refugio } from '../../refugios/services/refugios.service';

export interface Evento {
  _id: string;
  titulo: string;
  descripcion: string;
  imagenPrincipal: string;
  fecha: Date;
  hora: string;
  ubicacion: string;
  organizador: Refugio;
}
export interface UsuarioInteresado {
  _id: string;
  nombre: string;
  correo: string;
}

@Injectable({
  providedIn: 'root'
})
export class EventosService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/eventos`;
  private interaccionesUrl = `${environment.apiUrl}/interacciones-eventos`;
  private notificacionesUrl = `${environment.apiUrl}/notificaciones`;
  
  getEventos(): Observable<Evento[]> {
    return this.http.get<Evento[]>(this.baseUrl);
  }

  getEventoById(id: string): Observable<Evento> {
    return this.http.get<Evento>(`${this.baseUrl}/${id}`);
  }

  addEvento(data: any, file: File): Observable<Evento> {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    formData.append('imagenPrincipal', file);
    return this.http.post<Evento>(this.baseUrl, formData);
  }

  updateEvento(id: string, data: any, file?: File): Observable<Evento> {
    const formData = new FormData();
    Object.keys(data).forEach(key => formData.append(key, data[key]));
    if (file) {
      formData.append('imagenPrincipal', file);
    }
    return this.http.patch<Evento>(`${this.baseUrl}/${id}`, formData);
  }

  deleteEvento(id: string): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
  
  getInteresados(eventoId: string): Observable<UsuarioInteresado[]> {
    return this.http.get<UsuarioInteresado[]>(`${this.interaccionesUrl}/por-evento/${eventoId}`);
  }
  sendNotificationToAttendees(eventoId: string, data: { titulo: string, cuerpo: string }): Observable<any> {
    return this.http.post(`${this.notificacionesUrl}/manual/evento/${eventoId}`, data);
  }

}