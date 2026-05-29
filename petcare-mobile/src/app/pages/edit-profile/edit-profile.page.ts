import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { AuthService } from 'src/app/core/auth.service';
import { UsuariosService } from 'src/app/core/usuarios.service';

@Component({
  selector: 'app-edit-profile',
  standalone: true,
  imports: [IonicModule, CommonModule, ReactiveFormsModule],
  templateUrl: './edit-profile.page.html',
})
export class EditProfilePage implements OnInit {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private usuariosService = inject(UsuariosService);
  private toastCtrl = inject(ToastController);
  private navCtrl = inject(NavController);

  profileForm: FormGroup;
  currentUser: any; // Deberíamos tener una interfaz para el usuario logueado

  constructor() {
    this.profileForm = this.fb.group({
      nombre: ['', Validators.required],
      correo: [{ value: '', disabled: true }],
      contrasena: ['', [Validators.minLength(8)]],
    });
  }

  ngOnInit() {
    // Obtenemos el usuario desde el token decodificado en AuthService
    const user = this.authService.getUserData(); // Necesitaremos añadir este método
    if (user) {
      this.currentUser = user;
      this.profileForm.patchValue(this.currentUser);
    }
  }

  async onSubmit() {
    if (this.profileForm.invalid) return;

    const formData = { ...this.profileForm.value };
    if (!formData.contrasena) {
      delete formData.contrasena;
    }

    this.usuariosService.updateMyProfile(formData).subscribe({
      next: async () => {
        const toast = await this.toastCtrl.create({ message: 'Perfil actualizado con éxito.', duration: 2000, color: 'success' });
        await toast.present();
        this.navCtrl.back();
      },
      error: async (err) => {
        const toast = await this.toastCtrl.create({ message: err.error.message || 'Error al actualizar.', duration: 3000, color: 'danger' });
        await toast.present();
      }
    });
  }
}