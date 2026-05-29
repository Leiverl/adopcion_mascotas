import { Component, OnInit, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { IonicModule } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { Evento, EventosService } from 'src/app/core/eventos.service';
import { switchMap } from 'rxjs';
import { InteraccionesService } from 'src/app/core/interacciones.service'; // Importar
import { UiService } from 'src/app/core/ui.service'; // Importar
@Component({
  selector: 'app-event-detail',
  templateUrl: './event-detail.page.html',
  styleUrls: ['./event-detail.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, DatePipe]
})
export class EventDetailPage implements OnInit {
  private activatedRoute = inject(ActivatedRoute);
  private eventosService = inject(EventosService);
  private interaccionesService = inject(InteraccionesService); // Inyectar
  private uiService = inject(UiService);

  public evento?: Evento;
  public isLoading = true;
  public estoyInteresado = false;

  ngOnInit() {
    this.activatedRoute.params.pipe(
      switchMap(({ id }) => {
        // Cargamos el evento y a la vez verificamos si el usuario está interesado
        this.interaccionesService.checkStatus(id).subscribe(status => {
          this.estoyInteresado = status.interesado;
        });
        return this.eventosService.getEventoById(id);
      })
    ).subscribe(data => {
      this.evento = data;
      this.isLoading = false;
    });
  }

  toggleInteres() {
    if (!this.evento) return;

    this.estoyInteresado = !this.estoyInteresado;
    const action = this.estoyInteresado
      ? this.interaccionesService.addInteres(this.evento._id)
      : this.interaccionesService.removeInteres(this.evento._id);

    action.subscribe({
      error: () => {
        this.estoyInteresado = !this.estoyInteresado; // Revertir si hay error
        this.uiService.showError('Ocurrió un error.');
      }
    });
  }
}