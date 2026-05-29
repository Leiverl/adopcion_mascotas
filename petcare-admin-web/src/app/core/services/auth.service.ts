import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { jwtDecode } from 'jwt-decode'; // <-- IMPORTAR

interface LoginResponse {
  accessToken: string;
}

// Interfaz para el payload decodificado del token
interface DecodedToken {
  id: string;
  correo: string;
  rol: 'ADMIN' | 'REFUGIO' | 'ADOPTANTE';
  iat: number;
  exp: number;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl;
  private decodedToken: DecodedToken | null = null;

  constructor() {
    // Al iniciar el servicio, intenta decodificar el token si existe
    const token = this.getToken();
    if (token) {
      this.decodedToken = jwtDecode(token);
    }
  }

  login(correo: string, contrasena: string): Observable<LoginResponse> {
    const url = `${this.baseUrl}/auth/login`;
    const body = { correo, contrasena };

    return this.http.post<LoginResponse>(url, body).pipe(
      tap(response => this.setSession(response.accessToken))
    );
  }

  private setSession(token: string): void {
    this.decodedToken = jwtDecode(token);
    localStorage.setItem('accessToken', token);
  }

  logout(): void {
    this.decodedToken = null;
    localStorage.removeItem('accessToken');
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('accessToken');
  }

  getToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  // --- NUEVOS MÉTODOS ---
  getUserRole(): 'ADMIN' | 'REFUGIO' | 'ADOPTANTE' | null {
    return this.decodedToken?.rol || null;
  }

  getUserId(): string | null {
    return this.decodedToken?.id || null;
  }
}