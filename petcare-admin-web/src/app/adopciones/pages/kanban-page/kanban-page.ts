import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdopcionesService, SolicitudAdopcion } from '../../services/adopciones.service';
import { UiService } from '../../../core/services/ui.service';
import { ChatModalComponent } from '../../../chat/components/chat-modal/chat-modal';

// CDK y Angular Material
import { CdkDragDrop, DragDropModule, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { MatCardModule } from '@angular/material/card';
import { MatMenuModule } from '@angular/material/menu';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog } from '@angular/material/dialog';
import { ConfirmationDialogComponent } from '../../../shared/components/confirmation-dialog/confirmation-dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner'; // <-- IMPORTAR

@Component({
  selector: 'app-kanban-page',
  standalone: true,
  imports: [CommonModule, DragDropModule, MatCardModule, MatMenuModule, MatIconModule, MatButtonModule, MatProgressSpinnerModule], // <-- AÑADIR MatProgressSpinnerModule
  templateUrl: './kanban-page.html',
  styleUrl: './kanban-page.scss'
})
export class KanbanPageComponent implements OnInit {
  private adopcionesService = inject(AdopcionesService);
  private uiService = inject(UiService);
  private dialog = inject(MatDialog);

  nuevas: SolicitudAdopcion[] = [];
  enRevision: SolicitudAdopcion[] = [];
  aprobadas: SolicitudAdopcion[] = [];
  rechazadas: SolicitudAdopcion[] = [];

  ngOnInit(): void {
      this.loadSolicitudes();
  }

  loadSolicitudes(): void {
    this.adopcionesService.getSolicitudes().subscribe(solicitudes => {
      this.nuevas = solicitudes.filter(s => s.estado === 'NUEVA');
      this.enRevision = solicitudes.filter(s => s.estado === 'EN_REVISION');
      this.aprobadas = solicitudes.filter(s => s.estado === 'APROBADA');
      this.rechazadas = solicitudes.filter(s => s.estado === 'RECHAZADA');
    });
  }

  // --- MÉTODO DROP COMPLETAMENTE MODIFICADO ---
  drop(event: CdkDragDrop<SolicitudAdopcion[]>) {
    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
    } else {
      const solicitud = event.previousContainer.data[event.previousIndex];
      const nuevoEstado = event.container.id.toUpperCase();

      // 1. Mover la tarjeta en la UI al instante (Actualización Optimista)
      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex,
      );
      
      // 2. Si es 'APROBADA', marcamos que está procesando
      if (nuevoEstado === 'APROBADA') {
        solicitud.isProcessing = true;
      }
      
      // 3. Llamamos a la API en segundo plano
      this.adopcionesService.updateEstadoSolicitud(solicitud._id, nuevoEstado).subscribe({
        next: () => {
          this.uiService.showSuccess(`Solicitud movida a "${nuevoEstado}"`);
          // Cuando la API responde, quitamos el indicador
          solicitud.isProcessing = false;
        },
        error: (err) => {
          this.uiService.showError('No se pudo actualizar el estado.');
          // Si falla, revertimos el movimiento en la UI
          transferArrayItem(
            event.container.data,
            event.previousContainer.data,
            event.currentIndex,
            event.previousIndex,
          );
          solicitud.isProcessing = false;
        }
      });
    }
  }

  onDeleteSolicitud(solicitud: SolicitudAdopcion): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Confirmar Eliminación',
        message: `¿Estás seguro de que deseas eliminar la solicitud para ${solicitud.mascota?.nombre}?`
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.adopcionesService.deleteSolicitud(solicitud._id).subscribe({
          next: () => {
            this.uiService.showSuccess('Solicitud eliminada.');
            this.loadSolicitudes(); 
          },
          error: (err) => this.uiService.showError(err.error.message)
        });
      }
    });
  }

  onOpenChat(solicitud: SolicitudAdopcion): void {
    const conversacionId = solicitud.conversacion?._id;
    
    if (conversacionId) {
        this.dialog.open(ChatModalComponent, {
          width: '450px',
          height: '70vh',
          data: { solicitud, conversacionId }
        });
    } else {
        this.uiService.showError("No se encontró una conversación para esta solicitud.");
    }
  }
}