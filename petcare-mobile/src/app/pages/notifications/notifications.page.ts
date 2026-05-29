import { Component, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { IonicModule, ViewWillEnter } from '@ionic/angular';
import { Notificacion, NotificacionesService } from 'src/app/core/notificaciones.service';
import { Router, RouterModule } from '@angular/router';
import { UiService } from 'src/app/core/ui.service';

interface GroupedNotification {
  dateLabel: string;
  notifications: Notificacion[];
}

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [IonicModule, CommonModule, RouterModule, DatePipe],
  templateUrl: './notifications.page.html',
  styleUrls: ['./notifications.page.scss'],
})
export class NotificationsPage implements ViewWillEnter {
  private notificacionesService = inject(NotificacionesService);
  private router = inject(Router);
  private uiService = inject(UiService);

  public groupedNotifications: GroupedNotification[] = [];
  public isLoading = true;

  ionViewWillEnter() {
    this.loadNotifications();
  }

  loadNotifications() {
    this.isLoading = true;
    this.notificacionesService.getMisNotificaciones().subscribe(data => {
      this.groupedNotifications = this.groupNotificationsByDate(data);
      this.isLoading = false;
    });
  }

  private groupNotificationsByDate(notifications: Notificacion[]): GroupedNotification[] {
    const groups: { [key: string]: Notificacion[] } = {};

    notifications.forEach(notif => {
      const date = new Date(notif.createdAt);
      const today = new Date();
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      let key = date.toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

      if (date.toDateString() === today.toDateString()) {
        key = 'Hoy';
      } else if (date.toDateString() === yesterday.toDateString()) {
        key = 'Ayer';
      }

      if (!groups[key]) {
        groups[key] = [];
      }
      groups[key].push(notif);
    });

    return Object.keys(groups).map(key => ({
      dateLabel: key,
      notifications: groups[key]
    }));
  }

  handleNotificationClick(notificacion: Notificacion) {
    // Si la notificación no está leída, la marcamos
    if (!notificacion.leida) {
      this.notificacionesService.markAsRead(notificacion._id).subscribe(() => {
        notificacion.leida = true; // Actualiza la UI al instante
      });
    }

    // Navegamos a la ruta si existe
    if (notificacion.ruta) {
      this.router.navigateByUrl(notificacion.ruta);
    }
  }

  markAllAsRead() {
    this.notificacionesService.markAllAsRead().subscribe(() => {
      // Actualiza la UI para todas las notificaciones
      this.groupedNotifications.forEach(group => {
        group.notifications.forEach(n => n.leida = true);
      });
      this.uiService.showSuccess('Todas las notificaciones marcadas como leídas.');
    });
  }
  
  onDelete(notificationId: string, event: Event) {
    event.stopPropagation();
    this.notificacionesService.deleteNotificacion(notificationId).subscribe(() => {
      this.uiService.showSuccess('Notificación eliminada.');
      this.loadNotifications();
    });
  }

  getIconForNotification(titulo: string): string {
    if (titulo.toLowerCase().includes('solicitud')) return 'document-text-outline';
    if (titulo.toLowerCase().includes('evento')) return 'calendar-outline';
    return 'notifications-outline';
  }
}