import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { IonicModule, ToastController } from '@ionic/angular';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from 'src/app/core/auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.page.html',
  styleUrls: ['./register.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, ReactiveFormsModule, RouterModule]
})
export class RegisterPage {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private toastCtrl = inject(ToastController);

  registerForm: FormGroup;

  constructor() {
    this.registerForm = this.fb.group({
      nombre: ['', [Validators.required]],
      correo: ['', [Validators.required, Validators.email]],
      contrasena: ['', [Validators.required, Validators.minLength(8)]],
    });
  }

  async onRegister() {
    if (this.registerForm.invalid) {
      this.registerForm.markAllAsTouched();
      return;
    }

    this.authService.register(this.registerForm.value).subscribe({
      next: async () => {
        const toast = await this.toastCtrl.create({
          message: '¡Registro exitoso! Ahora puedes iniciar sesión.',
          duration: 3000,
          color: 'success'
        });
        await toast.present();
        this.router.navigateByUrl('/login');
      },
      error: async (err) => {
        const toast = await this.toastCtrl.create({
          message: err.error.message || 'Error en el registro. Inténtalo de nuevo.',
          duration: 3000,
          color: 'danger'
        });
        await toast.present();
      }
    });
  }
}