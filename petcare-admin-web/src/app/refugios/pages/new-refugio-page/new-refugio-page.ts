import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { Refugio, RefugiosService } from '../../services/refugios.service';
import { UiService } from '../../../core/services/ui.service';
import { switchMap } from 'rxjs';
import { Usuario, UsuariosService } from '../../../usuarios/services/usuarios.service';
// Angular Material
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { MatSelectModule } from '@angular/material/select';

@Component({
  selector: 'app-new-refugio-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatProgressSpinnerModule, MatIconModule, MatSelectModule ],
  templateUrl: './new-refugio-page.html',
  styleUrl: './new-refugio-page.scss'
})
export class NewRefugioPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private refugiosService = inject(RefugiosService);
  private uiService = inject(UiService);
  private router = inject(Router);
  private activatedRoute = inject(ActivatedRoute);
  private usuariosService = inject(UsuariosService);
  
  public refugioForm: FormGroup;
  private selectedFile?: File;
  public isEditMode = false;
  private currentRefugioId?: string;
  public isLoading = false;
  public logoPreview?: string;
   public availableOwners: Usuario[] = [];

  constructor() {
    this.refugioForm = this.fb.group({
      nombre: ['', Validators.required],
      direccion: ['', Validators.required],
      infoContacto: ['', Validators.required],
      historia: ['', Validators.required],
      propietario: ['', Validators.required],
    });
  }

  ngOnInit(): void {
    // Cargamos los usuarios disponibles para el selector
    this.usuariosService.getAvailableShelterUsers().subscribe(users => {
      this.availableOwners = users;
    });

    this.activatedRoute.params.pipe(
      switchMap(({ id }) => {
        if (!id) return [];
        this.isEditMode = true;
        this.currentRefugioId = id;
        return this.refugiosService.getRefugioById(id);
      })
    ).subscribe(refugio => {
      if (refugio) {
        this.refugioForm.patchValue({...refugio, propietario: (refugio.propietario as any)?._id});
        this.logoPreview = refugio.logo;

        // Si estamos editando, y el propietario actual no está en la lista de "disponibles",
        // lo añadimos para que aparezca seleccionado en el dropdown.
        const ownerExists = this.availableOwners.some(u => u._id === (refugio.propietario as any)._id);
        if (!ownerExists) {
          this.availableOwners.push(refugio.propietario as any);
        }
      }
    });
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFile = input.files[0];
      const reader = new FileReader();
      reader.onload = () => {
        this.logoPreview = reader.result as string;
      };
      reader.readAsDataURL(this.selectedFile);
    }
  }

  onSubmit(): void {
    if (this.refugioForm.invalid) {
      this.uiService.showError('Por favor, completa todos los campos requeridos.');
      return;
    }
    if (!this.isEditMode && !this.selectedFile) {
      this.uiService.showError('Debes seleccionar un logo para crear el refugio.');
      return;
    }

    this.isLoading = true;

    if (this.isEditMode && this.currentRefugioId) {
      // Lógica de Actualización
      this.refugiosService.updateRefugio(this.currentRefugioId, this.refugioForm.value, this.selectedFile)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Refugio actualizado exitosamente.');
            this.router.navigateByUrl('/refugios/list');
          },
          // --- CORRECCIÓN AQUÍ ---
          error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
          complete: () => this.isLoading = false
        });
    } else {
      // Lógica de Creación
      this.refugiosService.addRefugio(this.refugioForm.value, this.selectedFile!)
        .subscribe({
          next: () => {
            this.uiService.showSuccess('Refugio creado exitosamente.');
            this.router.navigateByUrl('/refugios/list');
          },
          // --- CORRECCIÓN AQUÍ ---
          error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
          complete: () => this.isLoading = false
        });
    }
  }
}