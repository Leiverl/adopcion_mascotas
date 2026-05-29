import { Component, OnInit, inject } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { FavoritosService } from '../core/favoritos.service';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  styleUrls: ['tabs.page.scss'],
  standalone: true,
  imports: [IonicModule],
})
export class TabsPage implements OnInit {
  private favoritosService = inject(FavoritosService);
  
  constructor() {}

  ngOnInit() {
    // Carga los favoritos del usuario al entrar a la sección principal
    this.favoritosService.loadMyFavorites();
  }
}