import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { io, Socket } from 'socket.io-client';
import { environment } from '../../../environments/environment';
import { AuthService } from '../../core/services/auth.service';
import { HttpClient } from '@angular/common/http';

export interface Mensaje {
  _id: string;
  cuerpo: string;
  remitente: { _id: string, nombre: string };
  createdAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class ChatService {
  private socket: Socket;
  private authService = inject(AuthService);
  private http = inject(HttpClient);
  
  constructor() {
    const userId = this.authService.getUserId();
    const socketUrl = environment.apiUrl.replace('/api/v1', '');
    this.socket = io(socketUrl, {
      autoConnect: false,
      query: { userId }
    });
  }

  connect() {
    this.socket.connect();
  }

  disconnect() {
    this.socket.disconnect();
  }

  sendMessage(conversacionId: string, texto: string) {
    this.socket.emit('enviarMensaje', { conversacionId, texto });
  }

  onNewMessage(): Observable<Mensaje> {
    return new Observable(observer => {
      this.socket.on('nuevoMensaje', (mensaje) => {
        observer.next(mensaje);
      });
    });
  }

  getHistory(conversacionId: string): Observable<Mensaje[]> {
    return this.http.get<Mensaje[]>(`${environment.apiUrl}/conversaciones/${conversacionId}/mensajes`);
  }

  sendTyping(conversacionId: string) {
    this.socket.emit('usuarioEscribiendo', { conversacionId });
  }

  onTyping(): Observable<{ conversacionId: string }> {
    return new Observable(observer => {
      this.socket.on('estaEscribiendo', (data) => observer.next(data));
    });
  }
}