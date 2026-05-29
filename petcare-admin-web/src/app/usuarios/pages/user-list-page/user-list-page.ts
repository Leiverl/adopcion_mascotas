import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { Usuario, UsuariosService } from '../../services/usuarios.service';
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
  selector: 'app-user-list-page',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTableModule, MatButtonModule, MatIconModule, MatTooltipModule, MatCardModule, MatProgressSpinnerModule],
  templateUrl: './user-list-page.html',
  styleUrl: './user-list-page.scss'
})
export class UserListPageComponent implements OnInit {
  private usuariosService = inject(UsuariosService);
  private uiService = inject(UiService);
  private dialog = inject(MatDialog);
  private router = inject(Router);

  public usuarios: Usuario[] = [];
  public displayedColumns: string[] = ['nombre', 'correo', 'rol', 'acciones'];
  public isLoading = true;

  ngOnInit(): void {
    this.loadUsuarios();
  }

  loadUsuarios(): void {
    this.isLoading = true;
    this.usuariosService.getUsuarios().subscribe({
      next: (data) => {
        this.usuarios = data;
        this.isLoading = false;
      },
      error: () => {
        this.uiService.showError('No se pudo cargar la lista de usuarios.');
        this.isLoading = false;
      }
    });
  }

  onEdit(usuarioId: string): void {
    this.router.navigate(['/usuarios/edit', usuarioId]);
  }

  onDelete(usuarioId: string, usuarioNombre: string): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Confirmar Eliminación',
        message: `¿Estás seguro de que deseas eliminar al usuario "${usuarioNombre}"?`
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.usuariosService.deleteUsuario(usuarioId).subscribe({
          next: () => {
            this.uiService.showSuccess(`Usuario "${usuarioNombre}" eliminado exitosamente.`);
            this.loadUsuarios();
          },
          error: (err) => this.uiService.showError(err.error.message)
        });
      }
    });
  }
}