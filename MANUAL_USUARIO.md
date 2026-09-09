# 🐾 PetCare — Manual de Usuario

<p align="center">
  Plataforma integral para la adopción de mascotas
  <br>
  <strong>App Móvil</strong> · <strong>Panel de Administración</strong>
</p>

---

## 📱 App Móvil (PetCare)

La aplicación móvil permite a los adoptantes descubrir mascotas, enviar solicitudes de adopción, chatear con refugios y gestionar su perfil.

### 1. Primeros pasos

> **📸 Aquí va una imagen real:** Pantalla de bienvenida de la app con el logo de PetCare y los botones de "Iniciar sesión" y "Registrarse".

#### Registro

1. Abre la aplicación y presiona **Registrarse**
2. Completa tus datos: nombre, correo electrónico, contraseña y teléfono
3. Presiona **Crear cuenta**
4. Inicia sesión con tu correo y contraseña

> También puedes iniciar sesión con **Google** si el administrador habilitó esa opción.

> **📸 Aquí va una imagen real:** Captura del formulario de registro con los campos nombre, correo, contraseña y teléfono.

### 2. Pantalla principal (navegación inferior)

> **📸 Aquí va una imagen real:** Captura de la pantalla principal con la barra de navegación inferior mostrando los 5 íconos (Descubrir, Favoritos, Chat, Eventos, Perfil) y el contenido de la sección "Descubrir".

Una vez dentro, verás una barra inferior con 5 secciones:

| Ícono | Sección | Descripción |
|---|---|---|
| 🧭 | **Descubrir** | Explora mascotas disponibles para adopción |
| ❤️ | **Favoritos** | Tus mascotas guardadas |
| 💬 | **Chat** | Conversaciones con refugios y adoptantes |
| 📅 | **Eventos** | Ferias de adopción y actividades |
| 👤 | **Perfil** | Tus datos, solicitudes y configuración |

### 3. Descubrir mascotas

> **📸 Aquí va una imagen real:** Captura del card swiper mostrando una tarjeta de mascota con foto, nombre, edad y raza.

En la pantalla **Descubrir** puedes:

- **Navegar** las mascotas con un deslizador tipo carta (card swiper)
- **Filtrar** por especie, tamaño, edad y ubicación usando el botón de filtros
- **Dar like** ❤️ a una mascota para guardarla en favoritos
- **Tocar una tarjeta** para ver el detalle completo

En la pantalla de **detalle** de una mascota encontrarás:

- Fotos del animal
- Nombre, edad, raza, tamaño y color
- Descripción y personalidad
- Ubicación del refugio
- Botón **Solicitar adopción** para iniciar el proceso

### 4. Favoritos

En la sección **Favoritos** se listan todas las mascotas que has marcado con like.

- Toca una mascota para ver su detalle
- Desliza para eliminar de favoritos
- Desde el detalle puedes solicitar la adopción

### 5. Solicitar una adopción

1. Desde el detalle de una mascota, presiona **Solicitar adopción**
2. Completa el formulario con tu motivación y experiencia con mascotas
3. Envía la solicitud
4. El refugio revisará tu solicitud y recibirás una notificación cuando cambie el estado

> Puedes dar seguimiento a tus solicitudes desde **Perfil → Mis adopciones**.

Los estados posibles son:

| Estado | Significado |
|---|---|
| `NUEVA` | Solicitud recibida, pendiente de revisión |
| `EN_REVISION` | El refugio está evaluando tu solicitud |
| `APROBADA` | ¡Felicitaciones! La adopción fue aprobada |
| `RECHAZADA` | La solicitud no fue aprobada en esta ocasión |

### 6. Chat en tiempo real

La sección **Chat** te permite comunicarte con refugios y otros usuarios.

- Las conversaciones se listan con el nombre del contacto y el último mensaje
- Toca una conversación para abrirla
- Escribe y envía mensajes de texto
- Verás indicadores cuando el otro usuario esté escribiendo
- Las notificaciones de nuevos mensajes aparecen aunque la app esté cerrada

### 7. Eventos

En la sección **Eventos** encontrarás ferias de adopción, jornadas de vacunación, charlas y más.

- **Lista de eventos** — Próximos eventos ordenados por fecha
- **Detalle del evento** — Fecha, hora, ubicación, descripción y fotos
- **Interesado** — Marca tu asistencia para que el organizador sepa
- Los eventos pasados se muestran como finalizados

### 8. Perfil y configuración

Desde tu **Perfil** puedes:

- Ver y editar tu foto, nombre, correo y teléfono
- **Mis adopciones** — Historial y estado de tus solicitudes
- **Mis eventos** — Eventos a los que has confirmado asistencia
- **Cerrar sesión**
- **Cambiar tema** — Alterna entre modo claro y oscuro desde el ícono en la esquina superior

---

## 🖥️ Panel de Administración (Web)

El panel de administración está diseñado para que los gestores de refugios y administradores del sistema gestionen todo el ecosistema PetCare.

### 1. Acceso

1. Abre la URL del panel administrativo
2. Ingresa con tu correo y contraseña de administrador
3. Serás redirigido al **Dashboard**

> Si no tienes credenciales, contacta al administrador del sistema.

### 2. Dashboard

La pantalla principal muestra un resumen con métricas clave:

- Total de mascotas registradas
- Solicitudes de adopción pendientes
- Refugios activos
- Adopciones completadas en el mes
- Eventos próximos
- Gráficos de actividad

### 3. Gestión de mascotas

**Ruta:** `/mascotas`

#### Listado
- Tabla con todas las mascotas registradas
- Columnas: foto, nombre, especie, raza, edad, refugio, estado
- Buscador y filtros por especie y estado
- Botones para editar o eliminar cada registro

#### Crear / Editar mascota

1. Presiona **Nueva mascota**
2. Completa los datos: nombre, especie, raza, edad, tamaño, color, descripción
3. Selecciona el refugio al que pertenece
4. Sube una o más fotos (arrastra o selecciona archivos)
5. Define el estado: `DISPONIBLE`, `EN_ADOPCION`, `ADOPTADO`
6. Guarda los cambios

### 4. Gestión de refugios

**Ruta:** `/refugios`

- **Listado** de refugios con nombre, dirección, teléfono y correo
- **Crear refugio** — Registra un nuevo refugio con sus datos de contacto y ubicación
- **Editar** — Modifica la información del refugio
- **Perfil público** — Vista de cómo los usuarios ven el refugio

### 5. Gestión de usuarios

**Ruta:** `/usuarios`

- **Listado** de todos los usuarios registrados
- **Crear usuario** — Registra manualmente un nuevo usuario (adoptante o administrador)
- **Editar** — Modifica nombre, correo, teléfono y rol
- Los usuarios no se pueden eliminar, solo desactivar

### 6. Solicitudes de adopción (Kanban)

**Ruta:** `/adopciones`

Este es un tablero estilo **Kanban** para gestionar el flujo de adopciones:

| Columna | Acción requerida |
|---|---|
| **NUEVA** | Solicitudes que acaban de llegar, pendientes de revisión |
| **EN REVISIÓN** | Arrastra aquí las que estás evaluando |
| **APROBADA** | Arrastra aquí cuando la adopción sea aceptada |
| **RECHAZADA** | Arrastra aquí si la solicitud no procede |

- Arrastra y suelta las tarjetas entre columnas para cambiar el estado
- Toca una tarjeta para ver el detalle de la solicitud: datos del adoptante, motivación y mascota solicitada
- El adoptante recibe una **notificación push** automática cuando cambia el estado

### 7. Gestión de eventos

**Ruta:** `/eventos`

#### Listado
- Tabla con todos los eventos (ferias, charlas, jornadas)
- Columnas: título, fecha, ubicación, asistentes interesados

#### Crear / Editar evento

1. Presiona **Nuevo evento**
2. Completa: título, descripción, fecha, hora, ubicación
3. Opcional: sube una imagen del evento
4. Guarda

- Los usuarios interesados se registran desde la app móvil
- Puedes ver cuántas personas confirmaron asistencia

### 8. Chat

**Ruta:** `/chat` (en construcción en el panel)

> El chat completo está disponible en la app móvil. El panel web mostrará próximamente la lista de conversaciones.

### 9. Perfil de administrador

**Ruta:** `/admin-perfil`

- Ver y editar tu foto, nombre y datos de contacto
- Cambiar contraseña

---

## 🔔 Notificaciones

El sistema envía notificaciones automáticas en estos casos:

| Evento | Canal |
|---|---|
| Nueva solicitud de adopción | Push (admin) |
| Cambio de estado de solicitud | Push (adoptante) |
| Nuevo mensaje en chat | Push (destinatario) |
| Recordatorio de evento próximo | Push (interesados) |

---

## 🆘 Soporte

Si encuentras algún problema o tienes dudas:

- **Errores técnicos** — Contacta al equipo de desarrollo
- **Problemas con adopciones** — Comunícate directamente con el refugio a través del chat
- **Sugerencias** — Envíalas al administrador del sistema

---

<p align="center">
  <sub>PetCare — Versión 1.0</sub>
  <br>
  <sub>Hecho con ❤️ para conectar mascotas con hogares</sub>
</p>
