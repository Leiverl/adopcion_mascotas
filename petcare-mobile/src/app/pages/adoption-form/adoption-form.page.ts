import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { SolicitudesService } from 'src/app/core/solicitudes.service';

@Component({
  selector: 'app-adoption-form',
  templateUrl: './adoption-form.page.html',
  styleUrls: ['./adoption-form.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, ReactiveFormsModule]
})
export class AdoptionFormPage implements OnInit {
  private fb = inject(FormBuilder);
  private activatedRoute = inject(ActivatedRoute);
  private solicitudesService = inject(SolicitudesService);
  private toastCtrl = inject(ToastController);
  private navCtrl = inject(NavController);
  
  public adoptionForm: FormGroup;
  private mascotaId?: string;

  constructor() {
    this.adoptionForm = this.fb.group({
      motivoAdopcion: ['', Validators.required],
      tieneOtrasMascotas: [null, Validators.required],
      descripcionVivienda: ['', Validators.required],
      acuerdoVisitas: [false, Validators.requiredTrue],
    });
  }

  ngOnInit() {
    this.mascotaId = this.activatedRoute.snapshot.paramMap.get('id') || undefined;
  }

  async onSubmit() {
    if (this.adoptionForm.invalid || !this.mascotaId) {
      this.adoptionForm.markAllAsTouched();
      const toast = await this.toastCtrl.create({
          message: 'Por favor, completa todas las preguntas.',
          duration: 3000,
          color: 'warning'
        });
        await toast.present();
      return;
    }

    const solicitudData = {
      mascota: this.mascotaId,
      respuestasFormulario: this.adoptionForm.value
    };

    this.solicitudesService.enviarSolicitud(solicitudData).subscribe({
      next: async () => {
        const toast = await this.toastCtrl.create({
          message: '¡Solicitud enviada con éxito! El refugio se pondrá en contacto contigo.',
          duration: 4000,
          color: 'success'
        });
        await toast.present();
        this.navCtrl.back(); // Vuelve a la página de detalle
      },
      error: async (err) => {
        const toast = await this.toastCtrl.create({
          message: err.error.message || 'No se pudo enviar la solicitud.',
          duration: 3000,
          color: 'danger'
        });
        await toast.present();
      }
    });
  }
}