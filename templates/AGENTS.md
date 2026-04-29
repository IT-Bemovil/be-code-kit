# Bemovil 2.0 — Agent Definitions

> Specialized agent configurations for the Bemovil 2.0 monorepo. Referenced by `@AGENTS.md` in the root `CLAUDE.md`.

---

## backend-dev

**Description**: Backend API development agent for Express 5 + TypeScript + Sequelize routes, helpers, models, and provider integrations.

**Context files**:
- `backend/CLAUDE.md` — backend-specific conventions and commands
- `context/guidelines.md` — project-wide technical rules
- `context/business_logic.md` — domain knowledge (hierarchy, products, providers)

**Key rules**:
- Zod validation on EVERY endpoint via `validateRequest({ schema, req })`
- Responses via `helpers/response` — never `res.json()` directly
- Throw typed errors (ErrorNotFound, ErrorBadRequest, etc.) — caught by `isect`
- When touching OLD routes (express-validator), migrate to NEW pattern (Zod + helpers)
- Path aliases: `@/app/*`, `@/config/*`, `@/helpers/*`, `@/models/*`, `@/middleware/*`
- JSON columns use `getJSON`/`setJSON` helpers
- Soft deletes via `paranoid: true`

---

## frontend-dev

**Description**: Frontend transactional portal agent for Vue 3 + Vite + Vuex + Tailwind development.

**Context files**:
- `frontend/CLAUDE.md` — frontend-specific conventions and commands
- `context/guidelines.md` — project-wide technical rules

**Key rules**:
- Centralized requests via `postRequest` method
- Vue 3 Options API (Composition API migration in progress)
- Vuex for state, vue-router for routing, vue-i18n for translations
- UI text in Spanish (neutral Colombian)
- TypeScript migration in progress — add types when touching files
- Blokay web components for reports (custom theme in `blokay-theme.scss`)

---

## admin-dev

**Description**: Admin portal agent (evolving into BeOne CRM/ERP) for internal staff interfaces.

**Context files**:
- `admin/CLAUDE.md` — admin-specific conventions and commands
- `context/guidelines.md` — project-wide technical rules

**Key rules**:
- Similar to frontend but simpler (no composables, no face detection)
- Blokay heavily used for parametric reports
- New features should consider modular architecture (BeOne CRM/ERP direction)
- Deploy: `npm run deploy:admin` (production S3), `npm run deploy:sandbox` (sandbox S3)

---

## proxy-dev

**Description**: Reverse proxy and deployment orchestrator agent for Green-Blue deployments.

**Context files**:
- `bemovil2-proxy/CLAUDE.md` — proxy-specific conventions and commands
- `context/guidelines.md` — project-wide technical rules

**Key rules**:
- Express 5 + http-proxy + Pino + node-schedule
- Green-Blue deployment orchestration (instance management on releases)
- Cron jobs via node-schedule
- Log forwarding to Axiom via Pino
- Source structure: `src/cron/`, `src/orchestrator/`, `src/proxy/`, `src/types.ts`

---

## migration-agent

**Description**: Specialized agent for migrating routes from OLD pattern (express-validator + middleware) to NEW pattern (Zod + helpers).

**Context files**:
- `backend/CLAUDE.md` — backend conventions
- `context/guidelines.md` — migration rules in Section 2

**Key rules**:
- Reference branch: `feature/migrate-middlewares-to-helpers`
- OLD: `export const validators = [check('field')..., validOrAbort, ...middleware]`
- NEW: Zod schema + `validateRequest({ schema, req })` + typed `Request<typeof schema>`
- Replace `express-validator` chains with equivalent Zod schemas
- Replace middleware array with direct helper calls in handler body
- Preserve all business logic — only change validation/auth layer

---

## e2e-test-agent

**Description**: Agent for writing E2E tests following Bemovil patterns and the E2E-Forge skill.

**Context files**:
- `backend/CLAUDE.md` — testing commands and patterns
- `context/guidelines.md` — testing requirements

**Key rules**:
- Tests colocated as `app/{domain}/{feature}/e2e.test.ts`
- Vitest with globals, no isolation, 30s timeout
- Tests run against REAL database (SSH tunnel) — no mocks
- Test happy paths and critical paths only
- Use Supertest for HTTP assertions
