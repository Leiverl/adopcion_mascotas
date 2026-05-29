import { Component, inject } from '@angular/core';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

// Angular Material
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule, MatListModule, MatIconModule],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.scss'
})
export class SidebarComponent {
  private authService = inject(AuthService);
  public userRole = this.authService.getUserRole();

  public menuItems = [
    { label: 'Dashboard', icon: 'dashboard', route: '/dashboard', roles: ['ADMIN', 'REFUGIO'] },
    { label: 'Mascotas', icon: 'pets', route: '/mascotas', roles: ['ADMIN', 'REFUGIO'] },
    { label: 'Adopciones', icon: 'assignment_turned_in', route: '/adopciones', roles: ['ADMIN', 'REFUGIO'] },
    { label: 'Refugios', icon: 'store', route: '/refugios', roles: ['ADMIN'] }, // <-- Solo para ADMIN
    { label: 'Eventos', icon: 'event', route: '/eventos', roles: ['ADMIN', 'REFUGIO'] },
    { label: 'Usuarios', icon: 'group', route: '/usuarios', roles: ['ADMIN'] },
  ];
}