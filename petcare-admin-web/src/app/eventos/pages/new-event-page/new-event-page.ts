import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { EventosService } from '../../services/eventos.service';
import { UiService } from '../../../core/services/ui.service';
import { switchMap } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';
import { Refugio, RefugiosService } from '../../../refugios/services/refugios.service';

// Angular Material
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSelectModule } from '@angular/material/select';

@Component({
  selector: 'app-new-event-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatDatepickerModule, MatProgressSpinnerModule, MatSelectModule],
  providers: [provideNativeDateAdapter()],
  templateUrl: './new-event-page.html',
  styleUrl: './new-event-page.scss'
})
export class NewEventPageComponent implements OnInit {
  // ... (inyecciones y propiedades sin cambios)
  private fb = inject(FormBuilder);
  private eventosService = inject(EventosService);
  private uiService = inject(UiService);
  private router = inject(Router);
  private authService = inject(AuthService);
  private refugiosService = inject(RefugiosService);
  private activatedRoute = inject(ActivatedRoute);

  public eventForm: FormGroup;
  private selectedFile?: File;
  public isEditMode = false;
  private currentEventId?: string;
  public isLoading = false;
  public esAdmin = false;
  public listaRefugios: Refugio[] = [];
  public imagenActual?: string;


  constructor() {
    this.esAdmin = this.authService.getUserRole() === 'ADMIN';
    this.eventForm = this.fb.group({
      titulo: ['', Validators.required],
      descripcion: ['', Validators.required],
      fecha: ['', Validators.required],
      hora: ['', Validators.required],
      ubicacion: ['', Validators.required],
      categoria: ['Jornada de Adopción', Validators.required],
      organizador: [''],
    });

    if (this.esAdmin) {
      this.eventForm.get('organizador')?.setValidators(Validators.required);
    }
  }

  ngOnInit(): void {
    // ... (ngOnInit sin cambios)
    if (this.esAdmin) {
      this.refugiosService.getRefugios().subscribe(data => this.listaRefugios = data);
    }

    this.activatedRoute.params.pipe(
      switchMap(({ id }) => {
        if (!id) return [];
        this.isEditMode = true;
        this.currentEventId = id;
        return this.eventosService.getEventoById(id);
      })
    ).subscribe(evento => {
      if (evento) {
        this.eventForm.patchValue({...evento, organizador: evento.organizador?._id });
        this.imagenActual = evento.imagenPrincipal;
      }
    });
  }

  onFileSelected(event: Event) {
    // ... (onFileSelected sin cambios)
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFile = input.files[0];
    }
  }

  onSubmit() {
    if (this.eventForm.invalid) {
      this.uiService.showError('Por favor, completa todos los campos requeridos.');
      return;
    }
    if (!this.isEditMode && !this.selectedFile) {
      this.uiService.showError('Debes seleccionar una imagen para crear el evento.');
      return;
    }

    this.isLoading = true;
    const formValue = this.eventForm.value;

    // --- CORRECCIÓN AQUÍ ---
    // Si el usuario no es admin, eliminamos el campo 'organizador' antes de enviarlo.
    // El backend se encargará de asignarlo automáticamente.
    if (!this.esAdmin) {
      delete formValue.organizador;
    }

    if (this.isEditMode && this.currentEventId) {
      this.eventosService.updateEvento(this.currentEventId, formValue, this.selectedFile).subscribe({
        next: () => {
          this.uiService.showSuccess('Evento actualizado exitosamente.');
          this.router.navigateByUrl('/eventos/list');
        },
        error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
        complete: () => this.isLoading = false
      });
    } else {
      this.eventosService.addEvento(formValue, this.selectedFile!).subscribe({
        next: () => {
          this.uiService.showSuccess('Evento creado exitosamente.');
          this.router.navigateByUrl('/eventos/list');
        },
        error: (err: any) => this.uiService.showError(err.error.message || 'Ocurrió un error'),
        complete: () => this.isLoading = false
      });
    }
  }
}