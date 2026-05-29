import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { Refugio, RefugiosService } from '../../services/refugios.service';
import { UiService } from '../../../core/services/ui.service';
import { ConfirmationDialogComponent } from '../../../shared/components/confirmation-dialog/confirmation-dialog';

// Angular Material
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-refugio-list-page',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTableModule, MatButtonModule, MatIconModule, MatTooltipModule, MatCardModule, MatProgressSpinnerModule],
  templateUrl: './refugio-list-page.html',
  styleUrl: './refugio-list-page.scss'
})
export class RefugioListPageComponent implements OnInit {
  private refugiosService = inject(RefugiosService);
  private uiService = inject(UiService);
  private dialog = inject(MatDialog);
  private router = inject(Router);

  public refugios: Refugio[] = [];
  public displayedColumns: string[] = ['logo', 'nombre', 'direccion', 'acciones'];
  public isLoading = true;

  ngOnInit(): void {
    this.loadRefugios();
  }

  loadRefugios(): void {
    this.isLoading = true;
    this.refugiosService.getRefugios().subscribe({
      next: (data) => {
        this.refugios = data;
        this.isLoading = false;
      },
      error: (err) => {
        this.uiService.showError('No se pudo cargar la lista de refugios.');
        this.isLoading = false;
      }
    });
  }

  onEdit(refugioId: string): void {
    this.router.navigate(['/refugios/edit', refugioId]);
  }

  onDelete(refugioId: string, refugioNombre: string): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Confirmar Eliminación',
        message: `¿Estás seguro de que deseas eliminar el refugio "${refugioNombre}"? Esta acción no se puede deshacer.`
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.refugiosService.deleteRefugio(refugioId).subscribe({
          next: () => {
            this.uiService.showSuccess(`Refugio "${refugioNombre}" eliminado exitosamente.`);
            this.loadRefugios(); // Recargar la lista
          },
          error: (err) => this.uiService.showError(err.error.message)
        });
      }
    });
  }
}