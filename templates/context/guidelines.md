# Bemovil 2.0 — Project Guidelines

> **Purpose**: Non-negotiable conventions, patterns, and architectural rules for this project. The orchestrator MUST read and enforce these on every task. Sub-agents receive relevant sections via CREA-structured prompts.

---

## Role

You are a senior full-stack developer building a production-grade digital products/services platform. You write clean, type-safe, performant code following the established patterns. You prioritize security, consistency with existing code, and maintainability across a 5-developer team.

---

## 1. Technology Stack

### Backend (Express API)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Runtime | Node.js 18+ | ESM modules (`"type": "module"`) |
| Framework | Express 5.2 | With clustering support (MULTI_CORE) |
| Language | TypeScript 5.9 strict | `noUnusedLocals`, `noUnusedParameters`, `noImplicitAny` |
| Validation | Zod 4 | On EVERY endpoint — error codes, not text |
| ORM | Sequelize 6 | MySQL2 driver, write/read separation supported |
| Database | MySQL | Paranoid mode (soft deletes) on most tables |
| Cache | Redis 5 | Cleared on primary process startup |
| Auth | JWT (jsonwebtoken) | + MFA via speakeasy (TOTP) |
| Logging | Pino + @axiomhq/pino | Centralized to Axiom |
| File Storage | AWS S3 | Via @aws-sdk/client-s3 |
| WebSocket | Socket.io 4 | Real-time features |
| Bundler | ESBuild | 3 entry points: main API, Davibank MS, WebSocket server |
| Testing | Vitest 4 + Supertest | E2E tests colocated as `e2e.test.ts` |
| Linter | ESLint 10 + Prettier | `eslint-plugin-simple-import-sort` |
| Security | detect-secrets | Scans for hardcoded secrets |
| AI | @anthropic-ai/sdk | For validation and intelligence features |

### Frontend (Transactional Portal)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | Vue 3.4 | Options API + Composition API migration in progress |
| Bundler | Vite 5 | With vite-plugin-ejs |
| State | Vuex 4 | With vuex-persistedstate |
| Router | Vue Router 4 | |
| Styling | Tailwind CSS 3.4 + SASS | Custom Blokay theme |
| i18n | vue-i18n 10 | Multi-language support |
| TypeScript | 5.9 | Migration in progress (`.ts` files but not fully typed yet) |
| Charts | Chart.js 3 + vue-chart-3 | |
| Face Detection | face-api.js | For identity validation |
| Document Scanner | opencv-document-scanner | For KYC document capture |

### Admin (Internal Portal → BeOne CRM/ERP)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | Vue 3.4 | Similar structure to frontend |
| Bundler | Vite 5 | |
| State | Vuex 4 | With vuex-persistedstate |
| Router | Vue Router 4.5 | |
| Styling | Tailwind CSS 3.4 + SASS | |
| Reports | Blokay web components | External service for parametric reports |

### Proxy (Reverse Proxy + Orchestrator)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | Express 5.2 | |
| Proxy | http-proxy | Reverse proxy to backend instances |
| Logging | Pino 10 | Forwards to Axiom |
| Scheduling | node-schedule | Cron jobs |
| Deployment | Green-Blue | Automatic instance management on releases |

### Infrastructure

| Component | Service |
|-----------|---------|
| Cloud | AWS (S3, EC2) |
| CI/CD | GitHub Actions (lint, build, test, secret-scan, deploy) |
| Deployment | GitHub Releases → proxy orchestrator → Green-Blue |
| Logs | Axiom |
| Reports | Blokay |
| Domains | bemovil.net, apiv2.bemovil.net, sandbox.bemovil.net, developers.bemovil.net, bepay.net.co |

---

## 2. Code Conventions

### Universal Rules
- **Code language**: English (variables, functions, types, comments, commits)
- **UI language**: Spanish (neutral Colombian), multi-language via i18n
- **TypeScript strict mode**: `interface` over `type`, no `any`
- **Exact versions** in package.json (no `^`) — backend enforces this, frontend still has some `^`
- **Conventional commits**: No AI attribution (no "Co-Authored-By")
- **Never build after changes** — CI handles builds
- **CLI tools**: Use `bat`/`rg`/`fd`/`sd`/`eza` — never `cat`/`grep`/`find`/`sed`/`ls`
- **RTK prefix**: Always prefix shell commands with `rtk` for token optimization
- **Prefer Tailwind**: Use Tailwind utility classes over inline styles or custom CSS/SCSS. Only use custom CSS when Tailwind cannot express the desired style or when it's significantly more convenient (e.g., complex animations, third-party component overrides)
- **Performance > Aesthetics**: Never sacrifice loading speed or runtime performance for visual effects. Animations and transitions must use GPU-accelerated properties (transform, opacity) and respect `prefers-reduced-motion`. Keep the app lightweight and fast above all

### Backend Conventions
- **Path aliases**: Always use `@/app/*`, `@/config/*`, `@/helpers/*`, `@/models/*`, `@/routes/*`, `@/middleware/*`, `@/ws/*`, `@/webSocketService/*`
- **Response format**: Always use `helpers/response` for consistent API responses — never `res.json()` directly
- **Error handling**: Throw typed errors (ErrorNotFound, ErrorBadRequest, etc.) — caught by `isect` (intersect-controller)
- **Error codes**: Use i18n error code keys (e.g., `auth.incorrect.userOrPassword`), not hardcoded text
- **Validation**: Zod schema at the top of every route.ts, validated via `validateRequest({ schema, req })`
- **Route pattern (NEW — target style)**:
  ```typescript
  // 1. Imports
  import { z } from 'zod';
  import { validateRequest } from 'config/validation/validators';
  // 2. Zod schema
  const mySchema = z.object({ ... });
  // 3. Default export handler
  export default async function (req: Request<typeof mySchema>, res: Response, next: Next) {
    const data = validateRequest({ schema: mySchema, req });
    // ... business logic ...
    response(res, req)(result);
  }
  ```
- **Route pattern (OLD — being migrated)**:
  ```typescript
  // Uses express-validator + middleware validators array
  export const validators = [check('field').isLength(...), validOrAbort, ...middleware];
  export default async function (req, res, next) { ... }
  ```
- **Migration rule**: When touching a route that uses the OLD pattern, migrate it to the NEW pattern (Zod + helpers). Reference branch: `feature/migrate-middlewares-to-helpers`
- **Provider classes**: All in `ws/class/`. Each extends a base pattern with `query()` and `sell()` methods
- **JSON columns**: Use `getJSON`/`setJSON` helpers for TEXT columns storing JSON (options, providerOptions, meta, alert)
- **Soft deletes**: Always use `paranoid: true` in model definitions
- **Write/Read DB separation**: Support via `DATABASE_WRITE_*` and `DATABASE_READ_*` env vars

### Frontend Conventions
- **Centralized requests**: Use the `postRequest` method for all backend calls
- **Component structure**: `src/components/`, `src/views/`, `src/layouts/`
- **State management**: Vuex stores in `src/store/`
- **Routing middleware**: `src/middleware/` for route guards
- **Services**: `src/services/` for API service layers
- **Composables**: `src/composables/` for Vue 3 composition utilities
- **i18n**: `src/i18n/` for translation files
- **Blokay integration**: Custom theme in `blokay-theme.scss`

### Admin Conventions
- Similar structure to frontend but simpler (no composables, no face detection)
- Blokay heavily used for parametric reports
- Evolving into BeOne CRM/ERP — new features should consider modular architecture

---

## 3. Architecture Patterns

### Backend: Route-Based Folder Structure
```
app/
├── auth/           # Authentication (login, register, MFA, sessions, identity)
├── admin/          # Admin-specific endpoints
├── brain/          # AI-powered features
├── certificates/   # Certificate generation
├── commerces/      # Business/commerce management
├── credits/        # Credit/loan features
├── feature-flags/  # Feature flag management
├── identity-session/ # Identity validation sessions
├── jobs/           # Background jobs
├── negotiations/   # Business negotiations
├── notifications/  # Push/SMS/email notifications
├── partners/       # Partner management
├── products/       # Product catalog and management
├── reports/        # Report generation
├── roles/          # Role-based access control
├── transactions/   # Transaction processing
├── users/          # User management
├── visitant/       # Visitor/prospect management
├── walletDale/     # Wallet integration (Dale)
├── webhooks/       # Webhook receivers
└── types.d.ts      # Shared request/response types
```

### Backend: Centralized Error Handling
```
Request → Express → isect(controller) → try/catch
                                            ├── Custom Error (status + code) → response() with error code
                                            └── Unknown Error → response() with 500 + server.error
```
Error classes: `ErrorNotFound`, `ErrorBadRequest`, `ErrorUnauthorized`, `ErrorForbidden`, `ErrorServer`, `ErrorConflict`, `ErrorBadGateway`, `ErrorServiceUnavailable`

### Backend: Provider Abstraction
```
Sell Request → ws/sell.ts (QueryRequest/SellRequest) → ws/class/{provider}/index.ts → External API
                                                                    ↓
                                                          bemovil/ (SOAP via Sirse)
                                                          be-pay/ (REST)
                                                          davibank/ (WebSocket MS)
                                                          _dummy/ (Sandbox mock)
```

### Backend: Product Flexibility Pattern
Products are highly abstract — configuration stored in JSON columns:
- `options`: View config, form inputs, UI behavior, validation rules
- `providerOptions`: Provider-specific config, API parameters, mapping rules
- `meta`: Additional metadata
- This allows adding new products WITHOUT code changes — just DB configuration

### Proxy: Green-Blue Deployment
```
GitHub Release (tag) → GitHub Action → POST /proxy/startEnvironment
                                              ↓
                                    Proxy pulls new code → builds → starts new instance
                                              ↓
                                    Health check → swap traffic → terminate old instance
```

---

## 4. Security Rules

- **Input validation**: Zod on EVERY endpoint — no exceptions
- **Password hashing**: bcryptjs
- **JWT auth**: Tokens validated via `check-auth` middleware → `req.user`
- **MFA**: TOTP via speakeasy, validated on login when `confirmatedMFA` is true
- **Second password**: Required for sensitive products (`needSecondPassword` field)
- **CORS**: Currently allows all origins (needs tightening for production)
- **Secret scanning**: GitHub Action runs `detect-secrets` on every push
- **Device tracking**: Sessions bound to device IDs
- **Identity validation (KYC)**: Multi-step document verification with Infolaft risk checks
- **Integrity hash**: Error responses include SHA1 integrity hash (date + salt)
- **SQL injection prevention**: Sequelize ORM parameterized queries
- **No hardcoded secrets**: All secrets in `.env` files, validated by Zod schema in `config/env.config.ts`

### Roles & Permissions Architecture
Three-table system, customizable per business:
- **Rol**: Role definitions (e.g., Contador, Vendedor de caja, Mensajero, Administrador) — businesses define their own roles
- **RolPrivilege**: Specific action permissions (e.g., access panel, view report, update users)
- **RolPermission**: Junction table mapping privileges to roles

### Compliance & Audits
- ISO 9001 certified
- Periodic audits: white box testing, stress testing, continuity testing, security testing
- Regulatory requirements (SFC, Habeas Data, PCI-DSS) — details pending documentation

---

## 5. Testing Requirements

### Backend
```bash
rtk vitest run                              # E2E tests (real DB via SSH tunnel)
rtk vitest --coverage                       # Tests with coverage report
rtk tsc                                     # TypeScript type checking
rtk eslint ./                               # Lint
rtk detect-secrets scan --all-files         # Secret scanning
```

- Tests colocated with features: `app/{domain}/{feature}/e2e.test.ts`
- Uses Vitest with globals, no isolation (`--no-isolate`), 30s timeout
- Tests run against REAL database (SSH tunnel) — no mocks
- Test happy paths and critical paths only
- Coverage excludes: node_modules, migrations, tmp, config, dist, assets

### Frontend
```bash
rtk vue-tsc --noEmit                        # TypeScript check
rtk eslint ./                               # Lint
```
- No E2E tests yet (E2E-Forge skill being developed for this)

### CI/CD Pipeline (GitHub Actions)
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `lint.yaml` | Push/PR | ESLint check |
| `build.yaml` | Push/PR | TypeScript + ESBuild build |
| `test.yaml` | Push/PR | Vitest E2E tests |
| `secret-scan.yaml` | Push/PR | detect-secrets scan |
| `audit-dependencies.yaml` | Push/PR | Dependency vulnerability audit |
| `deploy.yaml` | Tag `v*.*.*` | Deploy via proxy Green-Blue |

### Deploy Convention
- Tags with `-` suffix (e.g., `v1.2.3-beta`) → Sandbox
- Tags without `-` (e.g., `v1.2.3`) → Production

---

## 6. Technical Gotchas

1. **Sirse SOAP bridge**: Telecom products (recharges, packages) route through Sirse via SOAP/WSDL. Bemovil 2 formats REST → SOAP before sending. Communication failures between platforms are routine — always check both sides
2. **Bridge migration**: Sirse is being stripped of DB interactions product-by-product. Some products are migrated, others still use Sirse's full stack. Check the current Bridge status before modifying provider classes
3. **express-validator vs Zod**: Some routes still use the OLD pattern (express-validator + middleware). When editing these, migrate to NEW pattern (Zod + helpers). Never mix both in the same route
4. **JSON columns**: `options`, `providerOptions`, `meta`, `alert` are TEXT columns storing JSON. Always use `getJSON`/`setJSON` sequelize helpers. These columns contain CRITICAL business config — treat them as structured data, not free-form text
5. **Frontend TypeScript**: Migration in progress. Not everything is typed. Don't assume full type safety on the frontend
6. **Admin ≠ Frontend**: Despite similar tech stacks, admin and frontend have different purposes, user bases, and evolving architectures (admin → BeOne CRM/ERP)
7. **SSH tunnel for tests**: Backend tests require an SSH tunnel to reach the database. The `npm test` script handles this via `scripts/ssh-tunnel.mjs`
8. **Sequelize adapted for TypeScript**: Sequelize was originally JS-focused. The team has adapted it with custom type definitions in `models/models.types.ts` and `models/sequelize.types.ts`
9. **Multi-country IDs**: Colombia = ID 1, Ecuador = ID 1000. Country constants: COL = 5, EC = 6. These are different lookups (business ID vs country ID)
10. **Request wrapping**: All requests wrap body data in `req.body.data` (not `req.body` directly). The `validateRequest` default target is `'data'`

---

*Last updated: 2026-04-27*
