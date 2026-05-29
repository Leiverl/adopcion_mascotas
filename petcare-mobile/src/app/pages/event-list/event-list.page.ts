import { Component, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { IonicModule, ViewWillEnter } from '@ionic/angular';
import { Evento, EventosService } from 'src/app/core/eventos.service';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-event-list',
  templateUrl: './event-list.page.html',
  styleUrls: ['./event-list.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule, DatePipe]
})
export class EventListPage implements ViewWillEnter {
  private eventosService = inject(EventosService);

  public upcomingEvents: Evento[] = [];
  public pastEvents: Evento[] = [];
  public isLoading = true;
  public segment: 'upcoming' | 'past' = 'upcoming'; // Segmento activo por defecto

  ionViewWillEnter() {
    this.isLoading = true;
    this.eventosService.getEventos().subscribe(data => {
      const now = new Date();
      // Filtramos los eventos en dos listas
      this.upcomingEvents = data.filter(e => new Date(e.fecha) >= now);
      this.pastEvents = data.filter(e => new Date(e.fecha) < now);
      this.isLoading = false;
    });
  }

  segmentChanged(event: any) {
    this.segment = event.detail.value;
  }
}