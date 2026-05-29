import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Refugio, RefugiosService } from '../../services/refugios.service';
import { UiService } from '../../../core/services/ui.service';

// Angular Material
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-perfil-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatProgressSpinnerModule, MatIconModule],
  templateUrl: './perfil-page.html',
  styleUrl: './perfil-page.scss'
})
export class PerfilPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private refugiosService = inject(RefugiosService);
  private uiService = inject(UiService);
  
  public profileForm: FormGroup;
  public currentProfile?: Refugio;
  private selectedFile?: File;
  public isLoading = false;

  constructor() {
    this.profileForm = this.fb.group({
      nombre: ['', Validators.required],
      direccion: ['', Validators.required],
      infoContacto: ['', Validators.required],
      historia: ['', Validators.required],
    });
  }

  ngOnInit(): void {
    this.isLoading = true;
    this.refugiosService.getMyProfile().subscribe({
        next: (profile: Refugio) => {
            this.currentProfile = profile;
            this.profileForm.patchValue(profile);
            this.isLoading = false;
        },
        error: (err: any) => {
            this.uiService.showError('No se pudo cargar el perfil del refugio.');
            this.isLoading = false;
        }
    });
  }

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFile = input.files[0];
      
      const reader = new FileReader();
      reader.onload = () => {
        this.currentProfile!.logo = reader.result as string;
      };
      reader.readAsDataURL(this.selectedFile);
    }
  }

  onSubmit() {
    if (this.profileForm.invalid || !this.currentProfile) return;
    
    this.isLoading = true;
    // --- CORRECCIÓN AQUÍ: de 'updateProfile' a 'updateRefugio' ---
    this.refugiosService.updateRefugio(this.currentProfile._id, this.profileForm.value, this.selectedFile)
      .subscribe({
        // --- CORRECCIÓN AQUÍ: Añadir tipo a 'updatedProfile' ---
        next: (updatedProfile: Refugio) => {
          this.uiService.showSuccess('Perfil actualizado exitosamente.');
          this.currentProfile = updatedProfile;
          this.selectedFile = undefined;
        },
        // --- CORRECCIÓN AQUÍ: Añadir tipo a 'err' ---
        error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
        complete: () => this.isLoading = false
      });
  }
}