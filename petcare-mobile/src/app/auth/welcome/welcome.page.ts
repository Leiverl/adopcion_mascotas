import { AfterViewInit, Component, NgZone, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ToastController } from '@ionic/angular';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from 'src/app/core/auth.service';
import { environment } from 'src/environments/environment';

// Le decimos a TypeScript que el objeto 'google' existirá en el scope global
declare var google: any;

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.page.html',
  styleUrls: ['./welcome.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule]
})
export class WelcomePage implements AfterViewInit {
  private authService = inject(AuthService);
  private router = inject(Router);
  private toastCtrl = inject(ToastController);
  private ngZone = inject(NgZone); // Necesario para la redirección desde el callback

  constructor() { }

  ngAfterViewInit(): void {
    // Inicializamos la librería de Google
    google.accounts.id.initialize({
      client_id: environment.GOOGLE_CLIENT_ID,
      callback: this.handleCredentialResponse.bind(this),
      auto_select: false,
      cancel_on_tap_outside: true,
    });
    
    // Renderizamos el botón de Google en el div con id="google-btn"
    google.accounts.id.renderButton(
      document.getElementById('google-btn'),
      { theme: 'outline', size: 'large', shape: 'pill', width: '300px', locale: 'es' }
    );
  }

  async handleCredentialResponse(response: any) {
    // Esta función es llamada por la librería de Google cuando el login es exitoso
    this.authService.loginWithGoogleToken(response.credential).subscribe({
      next: () => {
        // Usamos NgZone para asegurarnos de que la navegación ocurra dentro del contexto de Angular
        this.ngZone.run(() => {
          this.router.navigateByUrl('/tabs/discover', { replaceUrl: true });
        });
      },
      error: async (err: any) => {
        const toast = await this.toastCtrl.create({
          message: err.error.message || 'Error en el login con Google.',
          duration: 3000,
          color: 'danger'
        });
        await toast.present();
      }
    });
  }
}