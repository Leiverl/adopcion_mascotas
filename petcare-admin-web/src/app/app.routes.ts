import { Routes } from '@angular/router';
import { AuthLayoutComponent } from './auth/layouts/auth-layout/auth-layout';
import { LoginPageComponent } from './auth/pages/login-page/login-page';
import { AdminLayoutComponent } from './core/layouts/admin-layout/admin-layout';
import { DashboardPageComponent } from './dashboard/pages/dashboard-page/dashboard-page';
import { authGuard } from './core/guards/auth-guard';
import { ListPageComponent } from './mascotas/pages/list-page/list-page';
import { NewPetPageComponent } from './mascotas/pages/new-pet-page/new-pet-page';
import { KanbanPageComponent } from './adopciones/pages/kanban-page/kanban-page';
import { EventListPageComponent } from './eventos/pages/event-list-page/event-list-page';
import { NewEventPageComponent } from './eventos/pages/new-event-page/new-event-page';
import { PerfilPageComponent } from './refugios/pages/perfil-page/perfil-page';
import { RefugioListPageComponent } from './refugios/pages/refugio-list-page/refugio-list-page';
import { NewRefugioPageComponent } from './refugios/pages/new-refugio-page/new-refugio-page';
import { UserListPageComponent } from './usuarios/pages/user-list-page/user-list-page';
import { NewUserPageComponent } from './usuarios/pages/new-user-page/new-user-page';
import { AdminProfilePageComponent } from './admin/pages/admin-profile-page/admin-profile-page';
export const routes: Routes = [
  // Rutas de Autenticación (públicas)
  {
    path: 'auth',
    component: AuthLayoutComponent,
    children: [
      { path: 'login', component: LoginPageComponent },
      { path: '**', redirectTo: 'login' },
    ],
  },
  // Rutas del Panel de Administración (protegidas)
  {
    path: '', // Se accederá directamente con /dashboard, etc.
    component: AdminLayoutComponent,
    canActivate: [authGuard], // <-- GUARDIA PROTEGIENDO TODAS LAS RUTAS HIJAS
    children: [
      { path: 'dashboard', component: DashboardPageComponent },
       {
        path: 'mascotas',
        children: [
          { path: 'list', component: ListPageComponent },
          { path: 'new', component: NewPetPageComponent },
          { path: 'edit/:id', component: NewPetPageComponent },
          { path: '**', redirectTo: 'list' },
        ]
      },
      { path: 'adopciones', component: KanbanPageComponent },
      { 
        path: 'eventos', 
        children: [
          { path: 'list', component: EventListPageComponent },
          { path: 'new', component: NewEventPageComponent },
          { path: 'edit/:id', component: NewEventPageComponent },
          { path: '**', redirectTo: 'list' }
        ]
      },
      { path: 'perfil', component: PerfilPageComponent },
      {
        path: 'refugios',
        children: [
          { path: 'list', component: RefugioListPageComponent },
          { path: 'new', component: NewRefugioPageComponent },
          { path: 'edit/:id', component: NewRefugioPageComponent },
          { path: '**', redirectTo: 'list' }
        ]
      },
      {
        path: 'usuarios',
        children: [
          { path: 'list', component: UserListPageComponent },
          { path: 'new', component: NewUserPageComponent },
          { path: 'edit/:id', component: NewUserPageComponent },
          { path: '**', redirectTo: 'list' }
        ]
      },
      { path: 'admin-perfil', component: AdminProfilePageComponent },
      // Aquí añadiremos las rutas para mascotas, eventos, etc.
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  // Ruta por defecto si ninguna coincide
  {
    path: '**',
    redirectTo: 'auth',
  },
];