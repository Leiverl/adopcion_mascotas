import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Evento } from './eventos.service';

export interface Interaccion { _id: string, evento: Evento }

@Injectable({ providedIn: 'root' })
export class InteraccionesService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/interacciones-eventos`;

  addInteres(eventoId: string): Observable<any> {
    return this.http.post(this.apiUrl, { eventoId });
  }
  removeInteres(eventoId: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${eventoId}`);
  }
  checkStatus(eventoId: string): Observable<{ interesado: boolean }> {
    return this.http.get<{ interesado: boolean }>(`${this.apiUrl}/status/${eventoId}`);
  }
  getMisEventos(): Observable<Interaccion[]> {
    return this.http.get<Interaccion[]>(`${this.apiUrl}/mis-eventos`);
  }
}