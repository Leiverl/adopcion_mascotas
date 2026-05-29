import { Component, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { IonicModule, ViewWillEnter } from '@ionic/angular';
import { Interaccion, InteraccionesService } from 'src/app/core/interacciones.service';
import { RouterModule } from '@angular/router';
import { UiService } from 'src/app/core/ui.service';

@Component({
  selector: 'app-my-events',
  templateUrl: './my-events.page.html',
  styleUrls: ['./my-events.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule]
})
export class MyEventsPage implements ViewWillEnter {
  private interaccionesService = inject(InteraccionesService);
  private uiService = inject(UiService);
  public misEventos: Interaccion[] = [];
  public isLoading = true;

  ionViewWillEnter() {
    this.isLoading = true;
    this.interaccionesService.getMisEventos().subscribe(data => {
      this.misEventos = data;
      this.isLoading = false;
    });
  }

  // --- NUEVOS MÉTODOS ---
  onRemoveInterest(interaccion: Interaccion, event: Event) {
    event.stopPropagation();
    event.preventDefault();

    this.interaccionesService.removeInteres(interaccion.evento._id).subscribe(() => {
      this.misEventos = this.misEventos.filter(i => i._id !== interaccion._id);
      this.uiService.showSuccess('Ya no estás interesado en este evento.');
    });
  }

  getDaysRemaining(eventDate: Date): string {
    const today = new Date();
    const event = new Date(eventDate);
    today.setHours(0, 0, 0, 0);
    event.setHours(0, 0, 0, 0);

    const diffTime = event.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 0) return 'Finalizado';
    if (diffDays === 0) return '¡Es Hoy!';
    if (diffDays === 1) return 'Mañana';
    return `En ${diffDays} días`;
  }
}