import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { EventosService, UsuarioInteresado } from '../../services/eventos.service';

@Component({
  selector: 'app-interesados-modal',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatListModule, MatButtonModule, MatProgressSpinnerModule, MatIconModule],
  templateUrl: './interesados-modal.html',
})
export class InteresadosModalComponent implements OnInit {
  private eventosService = inject(EventosService);

  public interesados: UsuarioInteresado[] = [];
  public isLoading = true;

  constructor(@Inject(MAT_DIALOG_DATA) public data: { eventoId: string, eventoTitulo: string }) {}

  ngOnInit(): void {
    this.eventosService.getInteresados(this.data.eventoId).subscribe(users => {
      this.interesados = users.map((u: any) => u.usuario); // Extraemos el objeto usuario
      this.isLoading = false;
    });
  }
}