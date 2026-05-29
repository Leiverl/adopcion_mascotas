import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { Mascota, MascotasService } from '../../services/mascotas.service';
import { UiService } from '../../../core/services/ui.service';
import { ConfirmationDialogComponent } from '../../../shared/components/confirmation-dialog/confirmation-dialog';

// Angular Material
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'app-list-page',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTableModule, MatButtonModule, MatIconModule, MatTooltipModule, MatCardModule],
  templateUrl: './list-page.html',
  styleUrl: './list-page.scss'
})
export class ListPageComponent implements OnInit {
  private mascotasService = inject(MascotasService);
  private uiService = inject(UiService);
  private dialog = inject(MatDialog);
  private router = inject(Router);

  public mascotas: Mascota[] = [];
  public displayedColumns: string[] = ['foto', 'nombre', 'especie', 'raza', 'estado', 'acciones'];

  ngOnInit(): void {
    this.loadMascotas();
  }

  loadMascotas(): void {
    this.mascotasService.getMascotas().subscribe(data => {
      this.mascotas = data;
    });
  }

  onEdit(mascotaId: string): void {
    this.router.navigate(['/mascotas/edit', mascotaId]);
  }

  onDelete(mascotaId: string, mascotaNombre: string): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Confirmar Eliminación',
        message: `¿Estás seguro de que deseas eliminar a ${mascotaNombre}? Esta acción no se puede deshacer.`
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.mascotasService.deleteMascota(mascotaId).subscribe({
          next: () => {
            this.uiService.showSuccess(`Mascota "${mascotaNombre}" eliminada exitosamente.`);
            this.loadMascotas(); // Recargar la lista
          },
          error: (err) => this.uiService.showError(err.error.message)
        });
      }
    });
  }
}