import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface Notificacion {
  _id: string;
  titulo: string;
  cuerpo: string;
  leida: boolean;
  createdAt: string;
  ruta?: string;
}

@Injectable({ providedIn: 'root' })
export class NotificacionesService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/notificaciones`;

  getMisNotificaciones(): Observable<Notificacion[]> {
    return this.http.get<Notificacion[]>(`${this.apiUrl}/mis-notificaciones`);
  }
  deleteNotificacion(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
  markAsRead(id: string): Observable<any> {
    return this.http.patch(`${this.apiUrl}/${id}/leida`, {});
  }

  markAllAsRead(): Observable<any> {
    return this.http.post(`${this.apiUrl}/marcar-todas-leidas`, {});
  }
}