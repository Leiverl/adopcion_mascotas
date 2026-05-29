import { Component, EventEmitter, OnInit, Output, inject } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

// Angular Material
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [RouterModule, MatToolbarModule, MatIconModule, MatButtonModule, MatMenuModule],
  templateUrl: './header.html',
  styleUrl: './header.scss'
})
export class HeaderComponent implements OnInit {
  @Output() toggleSidenav = new EventEmitter<void>();

  private authService = inject(AuthService);
  private router = inject(Router);

  public profileLink = ''; // Propiedad para el enlace dinámico

  ngOnInit(): void {
    const userRole = this.authService.getUserRole();
    // Asignamos la ruta correcta según el rol
    if (userRole === 'ADMIN') {
      this.profileLink = '/admin-perfil';
    } else if (userRole === 'REFUGIO') {
      this.profileLink = '/perfil';
    }
  }

  onLogout(): void {
    this.authService.logout();
    this.router.navigateByUrl('/auth/login');
  }
}