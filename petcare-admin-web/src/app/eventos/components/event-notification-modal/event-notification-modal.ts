import { Component, Inject, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { UiService } from '../../../core/services/ui.service';
import { Evento, EventosService } from '../../services/eventos.service';

@Component({
  selector: 'app-event-notification-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule],
  templateUrl: './event-notification-modal.html',
})
export class EventNotificationModalComponent {
  private fb = inject(FormBuilder);
  private eventosService = inject(EventosService);
  private uiService = inject(UiService);
  
  public notificationForm: FormGroup;

  constructor(
    public dialogRef: MatDialogRef<EventNotificationModalComponent>,
    @Inject(MAT_DIALOG_DATA) public event: Evento,
  ) {
    this.notificationForm = this.fb.group({
      titulo: [`Recordatorio: ${this.event.titulo}`, Validators.required],
      cuerpo: ['', Validators.required],
    });
  }

  onSend(): void {
    if (this.notificationForm.invalid) return;

    this.eventosService.sendNotificationToAttendees(this.event._id, this.notificationForm.value)
      .subscribe({
        next: () => {
          this.uiService.showSuccess('Notificación enviada a todos los interesados.');
          this.dialogRef.close();
        },
        error: (err) => this.uiService.showError(err.error.message || 'Error al enviar la notificación'),
      });
  }
}