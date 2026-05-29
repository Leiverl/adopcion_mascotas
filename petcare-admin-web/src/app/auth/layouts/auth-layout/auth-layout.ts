import { Component } from '@angular/core';
import { RouterModule } from '@angular/router'; // <-- IMPORTAR

@Component({
  selector: 'app-auth-layout',
  standalone: true,
  imports: [
    RouterModule // <-- AÑADIR AQUÍ
  ],
  templateUrl: './auth-layout.html',
  styleUrl: './auth-layout.scss'
})
export class AuthLayoutComponent {

}