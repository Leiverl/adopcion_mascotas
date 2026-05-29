import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { Usuario, UsuariosService } from '../../services/usuarios.service';
import { UiService } from '../../../core/services/ui.service';
import { switchMap } from 'rxjs';

// Angular Material
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSelectModule } from '@angular/material/select';

@Component({
  selector: 'app-new-user-page',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatProgressSpinnerModule, MatSelectModule],
  templateUrl: './new-user-page.html',
  styleUrl: './new-user-page.scss'
})
export class NewUserPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private usuariosService = inject(UsuariosService);
  private uiService = inject(UiService);
  private router = inject(Router);
  private activatedRoute = inject(ActivatedRoute);

  public userForm: FormGroup;
  public isEditMode = false;
  private currentUserId?: string;
  public isLoading = false;
  public roles: string[] = ['ADMIN', 'REFUGIO', 'ADOPTANTE'];

  constructor() {
    this.userForm = this.fb.group({
      nombre: ['', Validators.required],
      correo: ['', [Validators.required, Validators.email]],
      rol: ['', Validators.required],
      contrasena: ['', [Validators.minLength(8)]],
    });
  }

  ngOnInit(): void {
    this.activatedRoute.params.pipe(
      switchMap(({ id }) => {
        if (!id) {
          // Modo Creación: la contraseña es requerida
          this.userForm.get('contrasena')?.setValidators([Validators.required, Validators.minLength(8)]);
          return [];
        }
        this.isEditMode = true;
        this.currentUserId = id;
        return this.usuariosService.getUsuarioById(id);
      })
    ).subscribe(usuario => {
      if (usuario) {
        this.userForm.reset(usuario);
      }
    });
  }

  onSubmit(): void {
    if (this.userForm.invalid) return;

    this.isLoading = true;
    const formData = this.userForm.value;

    // Si no se ingresó una nueva contraseña en modo edición, no la enviamos
    if (this.isEditMode && !formData.contrasena) {
      delete formData.contrasena;
    }

    if (this.isEditMode && this.currentUserId) {
      // Lógica de Actualización
      this.usuariosService.updateUsuario(this.currentUserId, formData)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Usuario actualizado exitosamente.');
            this.router.navigateByUrl('/usuarios/list');
          },
          error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
          complete: () => this.isLoading = false
        });
    } else {
      // Lógica de Creación
      this.usuariosService.addUsuario(formData)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Usuario creado exitosamente.');
            this.router.navigateByUrl('/usuarios/list');
          },
          error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
          complete: () => this.isLoading = false
        });
    }
  }
}