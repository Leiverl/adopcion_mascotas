import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { jwtDecode } from 'jwt-decode';

interface LoginResponse {
  accessToken: string;
}

// Interfaz para el payload decodificado del token
interface DecodedToken {
  id: string;
  correo: string;
  rol: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  private apiUrl = environment.apiUrl;

  // --- PROPIEDAD AÑADIDA ---
  private decodedToken: DecodedToken | null = null;

  constructor() {
    // Al iniciar el servicio, intenta decodificar el token si existe
    const token = this.getToken();
    if (token) {
      try {
        this.decodedToken = jwtDecode(token);
      } catch (error) {
        console.error('Error decoding token:', error);
        this.logout(); // Si el token es inválido, lo limpiamos
      }
    }
  }

  login(correo: string, contrasena: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/auth/login`, { correo, contrasena })
      .pipe(tap(response => this.setToken(response.accessToken)));
  }

  register(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/usuarios/registro`, userData);
  }

  loginWithGoogleToken(token: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/auth/google`, { token })
      .pipe(tap(response => this.setToken(response.accessToken)));
  }

  registerFcmToken(token: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/auth/register-fcm`, { fcmToken: token });
  }
  
  private setToken(token: string): void {
    this.decodedToken = jwtDecode(token);
    localStorage.setItem('accessToken', token);
  }

  getToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  logout(): void {
    this.decodedToken = null;
    localStorage.removeItem('accessToken');
  }
  
  // Este método ahora funcionará correctamente
  getUserData() {
    return this.decodedToken;
  }
  //registerFcmToken(token: string): Observable<any> {
    //return this.http.post(`${this.apiUrl}/auth/register-fcm`, { fcmToken: token });
  //}
}