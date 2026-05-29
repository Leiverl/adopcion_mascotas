import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MascotasService } from '../../services/mascotas.service';
import { UiService } from '../../../core/services/ui.service';
import { switchMap } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';
import { Refugio, RefugiosService } from '../../../refugios/services/refugios.service';

// Angular Material
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-new-pet-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  templateUrl: './new-pet-page.html',
  styleUrl: './new-pet-page.scss'
})
export class NewPetPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private mascotasService = inject(MascotasService);
  private uiService = inject(UiService);
  private router = inject(Router);
  private activatedRoute = inject(ActivatedRoute);
  private authService = inject(AuthService);
  private refugiosService = inject(RefugiosService);

  public petForm: FormGroup;
  public selectedFiles: File[] = [];
  public isEditMode = false;
  private currentPetId?: string;
  public isLoading = false;
  public esAdmin = false;
  public listaRefugios: Refugio[] = [];
  public especies: string[] = ['Perro', 'Gato', 'Conejo', 'Tortuga', 'Pajaro'];
  public fotosActuales: string[] = [];

  constructor() {
    this.esAdmin = this.authService.getUserRole() === 'ADMIN';

    this.petForm = this.fb.group({
      nombre: ['', Validators.required],
      especie: ['', Validators.required],
      raza: ['', Validators.required],
      edad: ['', [Validators.required, Validators.min(0)]],
      sexo: ['', Validators.required],
      tamano: ['', Validators.required],
      descripcion: ['', Validators.required],
      // El campo refugio ahora es opcional en la creación inicial del formulario
      refugio: [''],
    });

    // --- CORRECCIÓN 1: Hacemos que el campo 'refugio' sea obligatorio SOLO si el usuario es ADMIN ---
    if (this.esAdmin) {
      this.petForm.get('refugio')?.setValidators([Validators.required]);
    }
  }

  ngOnInit(): void {
    if (this.esAdmin) {
      this.refugiosService.getRefugios().subscribe(refugios => {
        this.listaRefugios = refugios;
      });
    }
    this.activatedRoute.params.pipe(
      switchMap(({ id }) => {
        if (id) {
          this.isEditMode = true;
          this.currentPetId = id;
          return this.mascotasService.getMascotaById(id);
        }
        return [];
      })
    ).subscribe(mascota => {
      if (mascota) {
        this.petForm.patchValue({ ...mascota, refugio: mascota.refugio._id });
        this.fotosActuales = mascota.galeriaFotos;
      }
    });
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.selectedFiles = Array.from(input.files);
    }
  }

  onSubmit(): void {
    if (this.petForm.invalid) {
      this.petForm.markAllAsTouched();
      return;
    }
    this.isLoading = true;
    
    // --- CORRECCIÓN 2: Preparamos los datos antes de enviarlos ---
    const formValue = { ...this.petForm.value };
    // Si no es admin, eliminamos el campo 'refugio', ya que el backend lo asignará.
    if (!this.esAdmin) {
      delete formValue.refugio;
    }

    if (this.isEditMode && this.currentPetId) {
      // Usamos 'formValue' en lugar de 'this.petForm.value'
      this.mascotasService.updateMascota(this.currentPetId, formValue, this.selectedFiles)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Mascota actualizada exitosamente.');
            this.router.navigateByUrl('/mascotas/list');
          },
          error: (err) => this.uiService.showError(err.error.message),
          complete: () => this.isLoading = false
        });
    } else {
      if (this.selectedFiles.length === 0) {
        this.uiService.showError('Debes seleccionar al menos una foto.');
        this.isLoading = false;
        return;
      }
      // Usamos 'formValue' en lugar de 'this.petForm.value'
      this.mascotasService.addMascota(formValue, this.selectedFiles)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Mascota creada exitosamente.');
            this.router.navigateByUrl('/mascotas/list');
          },
          error: (err) => this.uiService.showError(err.error.message),
          complete: () => this.isLoading = false
        });
    }
  }
}