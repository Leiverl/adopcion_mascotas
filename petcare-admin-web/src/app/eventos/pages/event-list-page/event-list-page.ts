import { Component, OnInit, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Evento, EventosService } from '../../services/eventos.service';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog } from '@angular/material/dialog';
import { UiService } from '../../../core/services/ui.service';
import { ConfirmationDialogComponent } from '../../../shared/components/confirmation-dialog/confirmation-dialog';
import { InteresadosModalComponent } from '../../components/interesados-modal/interesados-modal'; // <-- IMPORTAR
import { EventNotificationModalComponent } from '../../components/event-notification-modal/event-notification-modal';
@Component({
  selector: 'app-event-list-page',
  standalone: true,
  imports: [CommonModule, RouterModule, MatCardModule, MatButtonModule, MatIconModule, DatePipe],
  templateUrl: './event-list-page.html',
  styleUrl: './event-list-page.scss'
})
export class EventListPageComponent implements OnInit {
  private eventosService = inject(EventosService);
  private dialog = inject(MatDialog);
  private uiService = inject(UiService);

  public eventos: Evento[] = [];

  ngOnInit(): void {
    this.loadEventos();
  }

  loadEventos(): void {
    this.eventosService.getEventos().subscribe(data => {
      this.eventos = data;
    });
  }

  // --- NUEVO MÉTODO ---
  verInteresados(evento: Evento): void {
    this.dialog.open(InteresadosModalComponent, {
      width: '450px',
      data: { eventoId: evento._id, eventoTitulo: evento.titulo }
    });
  }

  onDelete(eventoId: string, eventoTitulo: string): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Confirmar Eliminación',
        message: `¿Estás seguro de que deseas eliminar el evento "${eventoTitulo}"?`
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.eventosService.deleteEvento(eventoId).subscribe({
          next: () => {
            this.uiService.showSuccess('Evento eliminado exitosamente.');
            this.loadEventos();
          },
          error: (err) => this.uiService.showError(err.error.message),
        });
      }
    });
  }

  onNotify(evento: Evento): void {
    this.dialog.open(EventNotificationModalComponent, {
      width: '500px',
      data: evento
    });
  }

}