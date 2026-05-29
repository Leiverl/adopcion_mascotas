import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { UiService } from '../../../core/services/ui.service';
import { UsuariosService } from '../../../usuarios/services/usuarios.service';

// Angular Material
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-admin-profile-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatProgressSpinnerModule],
  templateUrl: './admin-profile-page.html',
  styleUrl: './admin-profile-page.scss'
})
export class AdminProfilePageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private usuariosService = inject(UsuariosService);
  private uiService = inject(UiService);

  public profileForm: FormGroup;
  public isLoading = true;
  private adminId?: string | null;

  constructor() {
    this.profileForm = this.fb.group({
      nombre: ['', Validators.required],
      correo: [{ value: '', disabled: true }], // El correo no se puede editar
      contrasena: ['', [Validators.minLength(8)]],
    });
  }

  ngOnInit(): void {
    this.adminId = this.authService.getUserId();
    if (this.adminId) {
      this.usuariosService.getUsuarioById(this.adminId).subscribe({
        next: (admin) => {
          this.profileForm.patchValue(admin);
          this.isLoading = false;
        },
        error: () => {
          this.uiService.showError('No se pudo cargar el perfil.');
          this.isLoading = false;
        }
      });
    }
  }

  onSubmit(): void {
    if (this.profileForm.invalid || !this.adminId) return;

    this.isLoading = true;
    const formData = { ...this.profileForm.value };

    // Si el campo de contraseña está vacío, no lo enviamos
    if (!formData.contrasena) {
      delete formData.contrasena;
    }

    this.usuariosService.updateUsuario(this.adminId, formData).subscribe({
      next: () => {
        this.uiService.showSuccess('Perfil actualizado exitosamente.');
        this.profileForm.get('contrasena')?.reset();
      },
      error: (err: any) => this.uiService.showError(err.error.message || 'Error al actualizar'),
      complete: () => this.isLoading = false,
    });
  }
}