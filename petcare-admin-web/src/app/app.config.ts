import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { provideClientHydration } from '@angular/platform-browser';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideHttpClient, withInterceptors } from '@angular/common/http'; // <-- Importar withInterceptors
import { jwtInterceptor } from './core/interceptors/jwt-interceptor'; // <-- Importar nuestro interceptor

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideClientHydration(),
    provideAnimationsAsync(),
    // Modificamos provideHttpClient para incluir el interceptor
    provideHttpClient(withInterceptors([jwtInterceptor])) 
  ]
};