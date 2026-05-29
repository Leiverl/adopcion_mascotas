import { Routes } from '@angular/router';
import { TabsPage } from './tabs.page';

export const routes: Routes = [
  {
    path: '', // La ruta padre ya es 'tabs', así que esta es la base
    component: TabsPage,
    children: [
      // Pestaña Descubrir
      {
        path: 'discover',
        children: [
          {
            path: '', // Ruta: /tabs/discover
            loadComponent: () => import('../pages/discover/discover.page').then(m => m.DiscoverPage),
          },
          {
            path: ':id', // Ruta: /tabs/discover/123
            loadComponent: () => import('../pages/pet-detail/pet-detail.page').then(m => m.PetDetailPage),
          },
          {
            path: ':id/apply', // Ruta: /tabs/discover/123/apply
            loadComponent: () => import('../pages/adoption-form/adoption-form.page').then(m => m.AdoptionFormPage),
          }
        ]
      },
      // Pestaña Eventos
      {
        path: 'events',
        children: [
          {
            path: '', // Ruta: /tabs/events
            loadComponent: () => import('../pages/event-list/event-list.page').then(m => m.EventListPage)
          },
          {
            path: ':id', // Ruta: /tabs/events/123
            loadComponent: () => import('../pages/event-detail/event-detail.page').then(m => m.EventDetailPage)
          }
        ]
      },
      // Pestaña Notificaciones
      {
        path: 'notifications',
        loadComponent: () => import('../pages/notifications/notifications.page').then(m => m.NotificationsPage)
      },
      // Pestaña Favoritos
      {
        path: 'favorites',
        loadComponent: () => import('../pages/favorites/favorites.page').then(m => m.FavoritesPage)
      },
      // Pestaña Perfil
      {
        path: 'profile',
        children: [
          {
            path: '', // Ruta: /tabs/profile
            loadComponent: () => import('../pages/profile/profile.page').then(m => m.ProfilePage),
          },
          {
            path: 'applications', // Ruta: /tabs/profile/applications
            loadComponent: () => import('../pages/my-applications/my-applications.page').then(m => m.MyApplicationsPage)
          },
          {
            path: 'edit', // Ruta: /tabs/profile/edit
            loadComponent: () => import('../pages/edit-profile/edit-profile.page').then(m => m.EditProfilePage)
          },
          {
            path: 'my-events', // Ruta: /tabs/profile/my-events
            loadComponent: () => import('../pages/my-events/my-events.page').then(m => m.MyEventsPage)
          }
          // La ruta de chat se mueve de aquí
        ]
      },
      // --- RUTA DE CHAT CORREGIDA ---
      // Se coloca como una ruta principal dentro de las pestañas
      {
        path: 'chat/:conversacionId', 
        loadComponent: () => import('../pages/chat/chat.page').then(m => m.ChatPage)
      },
      // Redirección por defecto
      {
        path: '',
        redirectTo: 'discover',
        pathMatch: 'full',
      },
    ],
  },
];