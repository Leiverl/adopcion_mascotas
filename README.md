<p align="center">
  <img src="https://img.shields.io/badge/NestJS-11-E0234E?style=for-the-badge&logo=nestjs&logoColor=white" alt="NestJS 11">
  <img src="https://img.shields.io/badge/Angular-20-DD0031?style=for-the-badge&logo=angular&logoColor=white" alt="Angular 20">
  <img src="https://img.shields.io/badge/Flutter-3.8-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.8">
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB">
  <br>
  <img src="https://img.shields.io/badge/Railway-0B0D0E?style=for-the-badge&logo=railway&logoColor=white" alt="Railway">
  <img src="https://img.shields.io/badge/Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white" alt="Netlify">
  <img src="https://img.shields.io/badge/Socket.IO-010101?style=for-the-badge&logo=socket.io&logoColor=white" alt="Socket.IO">
  <img src="https://img.shields.io/badge/SendGrid-1A1B1F?style=for-the-badge&logo=sendgrid&logoColor=white" alt="SendGrid">
  <br>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge" alt="PRs welcome">
</p>

<h1 align="center">🐾 PetCare — Plataforma de Adopción de Mascotas</h1>

<p align="center">
  <strong>Un ecosistema completo para conectar refugios, adoptantes y mascotas en busca de un hogar.</strong>
  <br>
  API REST · Panel Admin · App Móvil · Chat en Tiempo Real
</p>

---

## 📑 Tabla de contenidos

- [Arquitectura](#-arquitectura)
- [Funcionalidades](#-funcionalidades)
- [Primeros pasos](#-cómo-empezar)
- [Scripts disponibles](#-scripts-disponibles)
- [Stack técnico](#-stack-técnico)
- [Documentación](#-documentación)
- [Manual de usuario](#-manual-de-usuario)
- [Licencia](#-licencia)

---

## 📦 Arquitectura

| Proyecto | Tecnología | Propósito |
|:---|:---|:---|
| [`petcare-api`](./petcare-api) | NestJS 11 + MongoDB + Mongoose | API REST con autenticación JWT, WebSockets, subida de imágenes y más |
| [`petcare-admin-web`](./petcare-admin-web) | Angular 20 + Angular Material | Panel de administración para gestionar refugios, mascotas, adopciones y usuarios |
| [`petcare_mobile_flutter`](./petcare_mobile_flutter) | Flutter + Provider + Firebase | App móvil para descubrir mascotas, enviar solicitudes y chatear |

> Cada paquete es **independiente** y se ejecuta desde su propia carpeta. No hay scripts en la raíz.

---

## 🧩 Funcionalidades

### 🔹 API (`petcare-api`)

Backend principal del ecosistema, desarrollado con **NestJS 11** y desplegado en **Railway**.

<details>
<summary><strong>Ver lista completa de características</strong></summary>

- **Autenticación** — JWT + Passport + Google OAuth
- **Gestión de usuarios** — CRUD completo con roles
- **Refugios y mascotas** — Catálogo con imágenes (Cloudinary)
- **Solicitudes de adopción** — Flujo completo (`NUEVA` → `EN_REVISION` → `APROBADA` / `RECHAZADA`)
- **Favoritos** — Marcado de mascotas y refugios
- **Eventos** — Ferias de adopción, charlas y más, con registro de asistentes
- **Chat en tiempo real** — WebSockets (Socket.IO) con conversaciones y mensajes
- **Notificaciones push** — Firebase Admin + tareas programadas (`@nestjs/schedule`)
- **Dashboard** — Estadísticas agregadas para administración
- **PDF** — Generación de certificados y reportes (PDFKit)
- **Correo electrónico** — Envío transaccional con SendGrid
- **Documentación Swagger** — Interfaz interactiva en `<host>/docs`

</details>

### 🔹 Panel Admin (`petcare-admin-web`)

Aplicación SPA construida con **Angular 20** y **Angular Material** para la gestión administrativa, desplegada en **Netlify** o **Vercel**.

<details>
<summary><strong>Ver lista completa de características</strong></summary>

- Login protegido con JWT y guardianes de ruta
- CRUD de mascotas, refugios, usuarios y eventos
- Tablero **Kanban** para gestionar solicitudes de adopción
- Chat en tiempo real con indicadores de escritura
- Dashboard con métricas clave
- Subida de fotos con vista previa

</details>

### 🔹 App Móvil (`petcare_mobile_flutter`)

Aplicación **Flutter** con **Material 3** y modo oscuro, diseñada para adoptantes.

<details>
<summary><strong>Ver lista completa de características</strong></summary>

- Descubrimiento de mascotas con filtros y card swiper
- Detalle completo de cada mascota con fotos
- Favoritos e interacciones (likes)
- Solicitudes de adopción desde la app
- Chat en tiempo real con otros usuarios
- Eventos cercanos con registro de interés
- Notificaciones push (Firebase Cloud Messaging)
- Autenticación con JWT
- Tema claro/oscuro persistente

</details>

---

## 🚀 Cómo empezar

### Requisitos previos

- Node.js ≥ 20
- Angular CLI 20 (`npm install -g @angular/cli`)
- Flutter SDK ≥ 3.8
- MongoDB (local o Atlas)
- Cuentas en **Cloudinary**, **SendGrid** y **Firebase** (opcional para desarrollo local)

### 1. API (`petcare-api`)

```bash
cd petcare-api
npm install
cp .env .env.local   # edita .env.local con tus credenciales (ver .env.example)
npm run start:dev     # http://localhost:3000
```

> **Variables requeridas en `.env.local`:**
> - `MONGODB_URI` — Conexión a MongoDB Atlas
> - `JWT_SECRET` — Clave secreta para firmar tokens
> - `CLOUDINARY_*` — Credenciales de Cloudinary
> - `SENDGRID_API_KEY` — Para envío de correos
> - `GOOGLE_CLIENT_ID` — Para OAuth con Google

### 2. Panel Admin (`petcare-admin-web`)

```bash
cd petcare-admin-web
npm install --legacy-peer-deps
ng serve              # http://localhost:4200
```

> ⚠️ Requiere `--legacy-peer-deps` por dependencias de Angular Material 20

### 3. App Flutter (`petcare_mobile_flutter`)

```bash
cd petcare_mobile_flutter
flutter pub get
flutter run           # requiere emulador o dispositivo físico
```

> El archivo `.env` con `API_URL` ya está incluido en el repo como asset (configurado en `pubspec.yaml`)

---

## 📋 Scripts disponibles

### API

| Comando | Descripción |
|:---|:---|
| `npm run start:dev` | Desarrollo con recarga automática (`--watch`) |
| `npm run build` | Compilación a `dist/` |
| `npm test` | Tests unitarios (Jest) |
| `npm run test:e2e` | Tests end-to-end (Jest + Supertest) |
| `npm run test:cov` | Cobertura de tests |
| `npm run lint` | ESLint con corrección automática |
| `npm run format` | Prettier (`singleQuote: true`, `trailingComma: "all"`) |
| `npm run start:prod` | Producción (`node dist/main`) |

### Panel Admin

| Comando | Descripción |
|:---|:---|
| `ng serve` | Servidor de desarrollo (`localhost:4200`) |
| `ng build` | Build de producción → `dist/petcare-admin-web/browser` |
| `ng test` | Tests unitarios (Karma + Jasmine) |

### App Flutter

| Comando | Descripción |
|:---|:---|
| `flutter run` | Ejecutar en dispositivo/emulador |
| `flutter test` | Tests unitarios |
| `flutter build apk` | Build Android (APK) |
| `flutter build ios` | Build iOS |
| `flutter build appbundle` | Build Android (AAB para Play Store) |

---

## 🛠 Stack técnico

| Área | Tecnologías |
|:---|:---|
| **Backend** | NestJS 11, Mongoose, Passport JWT, Socket.IO, Cloudinary, SendGrid, Firebase Admin, PDFKit, class-validator, class-transformer |
| **Panel Admin** | Angular 20, Angular Material, Socket.IO Client, jwt-decode, RxJS |
| **App Móvil** | Flutter 3.8, Provider, flutter_dotenv, socket_io_client, Firebase Messaging, Google Fonts (Poppins), intl |
| **Base de datos** | MongoDB (Atlas) |
| **Despliegue** | Railway (API), Netlify / Vercel (Admin), Stores (App) |
| **CI/CD** | Railway Nixpacks, Netlify/Vercel auto-deploy |

---

## 📚 Documentación

- **Swagger UI** — Disponible en `https://<host>/docs` cuando la API está corriendo (prefijo `/api/v1`)
- **AGENTS.md** — [Guía rápida para desarrollo](AGENTS.md)
- **MANUAL_USUARIO.md** — [Manual de usuario completo](MANUAL_USUARIO.md)

---

## 👥 Manual de usuario

Consulta el **[MANUAL_USUARIO.md](MANUAL_USUARIO.md)** para una guía paso a paso con capturas de pantalla sobre:

- 📱 **App móvil**: registro, descubrir mascotas, favoritos, adopciones, chat, eventos, perfil
- 🖥️ **Panel admin**: dashboard, CRUDs, tablero Kanban de adopciones, eventos

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**. Ver [LICENSE](LICENSE) [Leiver](https://github.com/Leiverl).

---

<p align="center">
  Hecho con ❤️ para ayudar a mascotas a encontrar un hogar
  <br>
  <sub>¿Te gustó el proyecto? ¡Dale una ⭐ en GitHub!</sub>
</p>
