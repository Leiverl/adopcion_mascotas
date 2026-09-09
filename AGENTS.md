# Adopción Mascotas – AGENTS.md

## Monorepo structure (4 independent packages, no root scripts)

| Package | Stack | Entrypoint | Deploy |
|---|---|---|---|
| `petcare-api/` | NestJS 11 + Mongoose + Swagger + JWT + Passport + Socket.IO + SendGrid + Cloudinary + Firebase Admin | `src/main.ts` → `api/v1` prefix, Swagger at `/docs`, port 3000 | Railway (`railway.json`) |
| `petcare-admin-web/` | Angular 20 + Angular Material | `src/main.ts` | Netlify (`netlify.toml`) / Vercel (`vercel.json`) |
| `petcare-mobile/` | Ionic 8/Angular 20 + Capacitor + Socket.IO client | `src/main.ts` | Capacitor build → stores |
| `petcare_mobile_flutter/` | Flutter + Provider + `flutter_dotenv` + `socket_io_client` + Firebase Messaging | `lib/main.dart` | stores |

Each package is self-contained. Run commands from the package root.

## API (`petcare-api/`)

```bash
npm run start:dev    # dev with --watch
npm run build        # nest build
npm run lint         # eslint --fix
npm run format       # prettier --write
npm test             # jest (unit tests)
npm run test:e2e     # jest --config ./test/jest-e2e.json
npm run test:cov     # jest --coverage
npm run start:prod   # node dist/main
```

- Requires `MONGODB_URI` and `JWT_SECRET` in `.env` (example present, DO NOT commit — `.env` is gitignored)
- `firebase-service-account.json` is gitignored — CI needs it injected
- Docker build: `node:20-alpine`, exposes `3000`, runs `start:prod`
- Jest config is inline in `package.json` (not a separate file)
- Swagger UI available at `<host>/docs`
- All API routes are under `api/v1/` prefix
- `strictNullChecks: false`, `noImplicitAny: false` — TypeScript is lenient
- Websocket chat gateway registered globally in `app.module.ts`

## Admin Web (`petcare-admin-web/`)

```bash
ng serve            # dev on localhost:4200
ng build            # production build → dist/petcare-admin-web/browser
ng test             # Karma + Jasmine
```

- Deploy requires `npm install --legacy-peer-deps` (specified in both `netlify.toml` and `vercel.json`)
- Styles: SCSS
- SPA – redirect all routes to `index.html` in deployment

## Ionic Mobile (`petcare-mobile/`)

```bash
ng serve            # dev
ng build            # build → www/
ng test             # Karma + Jasmine
ng lint             # ESLint for .ts and .html
```

- Capacitor native builds: `npx cap sync android` / `npx cap sync ios`
- Environment files in `src/environments/` — `environment.prod.ts` replaces `environment.ts` in production
- API URL configured in `environment.ts` (points to Render-hosted API by default)

## Flutter Mobile (`petcare_mobile_flutter/`)

```bash
flutter pub get     # install deps
flutter run         # dev
flutter test        # flutter_test
```

- `.env` file is bundled as an asset (`flutter_dotenv`) — contains `API_URL`
- Firebase setup: `firebase_core` + `firebase_messaging`
- Uses `provider` for state management
- Launcher icon configured via `flutter_launcher_icons`

## Testing quirks

- **API tests:** Jest with `ts-jest`, test files match `*.spec.ts`, test root is `src/`
- **Admin Web & Ionic:** Karma + Jasmine (Angular defaults), test files match `*.spec.ts`
- **Flutter:** standard `flutter_test`
- No integration/e2e tests are wired for the Angular apps beyond what `ng test` provides

## Key conventions

- **API formatting:** Prettier with `singleQuote: true`, `trailingComma: "all"`
- **API linting:** ESLint flat config (`eslint.config.mjs`)
- **Angular:** Standalone components, SCSS styles
- **Ionic mobile:** Uses `@ionic/angular-toolkit` schematics
- **API NestJS version:** v11 (check generator output with `@nestjs/schematics` v11)
