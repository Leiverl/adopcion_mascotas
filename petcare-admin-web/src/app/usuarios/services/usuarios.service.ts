import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Usuario {
  _id: string;
  nombre: string;
  correo: string;
  rol: 'ADMIN' | 'REFUGIO' | 'ADOPTANTE';
}

@Injectable({
  providedIn: 'root'
})
export class UsuariosService {
  private http = inject(HttpClient);
  private baseUrl = `${environment.apiUrl}/usuarios`;
  private notificacionesUrl = `${environment.apiUrl}/notificaciones`;

  getUsuarios(): Observable<Usuario[]> {
    return this.http.get<Usuario[]>(this.baseUrl);
  }

  getUsuarioById(id: string): Observable<Usuario> {
    return this.http.get<Usuario>(`${this.baseUrl}/${id}`);
  }

  addUsuario(data: Partial<Usuario>): Observable<Usuario> {
    // La creación usa el endpoint de registro público
    return this.http.post<Usuario>(`${this.baseUrl}/registro`, data);
  }

  updateUsuario(id: string, data: Partial<Usuario>): Observable<Usuario> {
    return this.http.patch<Usuario>(`${this.baseUrl}/${id}`, data);
  }

  deleteUsuario(id: string): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
  getAvailableShelterUsers(): Observable<Usuario[]> {
    return this.http.get<Usuario[]>(`${this.baseUrl}/disponibles/refugio`);
  }
  sendNotification(data: { usuarioId: string, titulo: string, cuerpo: string }): Observable<any> {
    return this.http.post(`${this.notificacionesUrl}/manual`, data);
  }
}