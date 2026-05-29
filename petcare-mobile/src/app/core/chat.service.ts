import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { io, Socket } from 'socket.io-client';
import { environment } from 'src/environments/environment';
import { AuthService } from './auth.service';

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
    const userId = this.authService.getUserData()?.id;
    const socketUrl = environment.apiUrl.replace('/api/v1', '');
    this.socket = io(socketUrl, {
      autoConnect: false,
      query: { userId }
    });
  }

  connect() { this.socket.connect(); }
  disconnect() { this.socket.disconnect(); }

  // --- CORRECCIÓN AQUÍ ---
  sendMessage(conversacionId: string, texto: string) {
    // Ahora enviamos el ID de la conversación, no el de la solicitud
    this.socket.emit('enviarMensaje', { conversacionId, texto });
  }

  onNewMessage(): Observable<Mensaje> {
    return new Observable(observer => {
      this.socket.on('nuevoMensaje', (mensaje) => observer.next(mensaje));
    });
  }

  // --- CORRECCIÓN AQUÍ ---
  getHistory(conversacionId: string): Observable<Mensaje[]> {
    // Apuntamos al endpoint corregido
    return this.http.get<Mensaje[]>(`${environment.apiUrl}/conversaciones/${conversacionId}/mensajes`);
  }
  
  // --- CORRECCIÓN AQUÍ ---
  sendTyping(conversacionId: string) {
    this.socket.emit('usuarioEscribiendo', { conversacionId });
  }

  onTyping(): Observable<{ conversacionId: string }> {
    return new Observable(observer => {
      this.socket.on('estaEscribiendo', (data) => observer.next(data));
    });
  }
}