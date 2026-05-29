import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface Usuario {
    _id: string;
    nombre: string;
    correo: string;
    rol: string;
}

@Injectable({
  providedIn: 'root'
})
export class UsuariosService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/usuarios`;

  // Este método es para que el usuario obtenga sus propios datos
  getMyProfile(): Observable<Usuario> {
    // Necesitaremos un endpoint para esto en el backend
    // Por ahora, reutilizaremos el servicio de auth
    return new Observable(); // Placeholder
  }

  updateMyProfile(data: { nombre?: string, contrasena?: string }): Observable<Usuario> {
    return this.http.patch<Usuario>(`${this.apiUrl}/mi-perfil`, data);
  }
}