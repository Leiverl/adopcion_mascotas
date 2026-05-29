import { Component, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { IonicModule, ViewWillEnter } from '@ionic/angular';
import { Solicitud, SolicitudesService } from 'src/app/core/solicitudes.service';
import { Browser } from '@capacitor/browser';
import { Router, RouterModule } from '@angular/router';
import { UiService } from 'src/app/core/ui.service';
@Component({
  selector: 'app-my-applications',
  templateUrl: './my-applications.page.html',
  styleUrls: ['./my-applications.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, DatePipe, RouterModule]
})
export class MyApplicationsPage implements ViewWillEnter {
  private solicitudesService = inject(SolicitudesService);
  private router = inject(Router);
  private uiService = inject(UiService);
  public solicitudes: Solicitud[] = [];
  public isLoading = true;

  ionViewWillEnter() {
    this.isLoading = true;
    this.solicitudesService.getMisSolicitudes().subscribe(data => {
      this.solicitudes = data;
      this.isLoading = false;
    });
  }

  async verCertificado(url: string | undefined) {
    if (!url) return;
    await Browser.open({ url });
  }

  goToChat(solicitud: Solicitud) {
    const conversacionId = (solicitud as any).conversacion?._id;
    if (conversacionId) {
      // Pasamos el nombre del refugio en el 'state' de la navegación
      const partnerName = solicitud.mascota.refugio.nombre;
      this.router.navigate(['/tabs/chat', conversacionId], { 
        state: { partnerName } 
      });
    } else {
      this.uiService.showError("No se encontró una conversación para esta solicitud.");
    }
  }

  getStatusColor(estado: string) {
    switch (estado) {
      case 'APROBADA': return 'success';
      case 'RECHAZADA': return 'danger';
      case 'EN_REVISION': return 'warning';
      default: return 'medium';
    }
  }

  // --- NUEVO MÉTODO ---
  getStatusIcon(estado: string): string {
    switch (estado) {
      case 'APROBADA': return 'checkmark-circle';
      case 'RECHAZADA': return 'close-circle';
      case 'EN_REVISION': return 'hourglass-outline';
      default: return 'document-text-outline';
    }
  }
}