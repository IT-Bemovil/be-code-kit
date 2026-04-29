@AGENTS.md

# Bemovil 2.0 — Digital Products & Services Platform

Monorepo with 4 sub-projects: Backend API, Frontend transactional portal, Admin internal portal (→ BeOne CRM/ERP), Proxy deployment orchestrator. Infra: AWS (S3, EC2) · GitHub Actions CI/CD · Axiom logs · Blokay reports.

## Read Before Coding

| Document | Purpose |
|----------|---------|
| `context/guidelines.md` | **Constitution** — stack, conventions, patterns, security, testing, gotchas |
| `context/business_logic.md` | **Domain** — entities, workflows, terminology, transaction engine, commissions |
| `context/user_context.md` | **User Profile** — identity, preferences, workflow style |
| `context/Bemovil2questions.md` | **Gaps** — unanswered questions that need user input |

## Sub-Project Routing

Each sub-project has its own CLAUDE.md with stack, commands, conventions, and deployment. **Always read the relevant sub-project file before coding.**

| Sub-Project | CLAUDE.md | Purpose |
|-------------|-----------|---------|
| Backend | `backend/CLAUDE.md` | Express 5 API · TypeScript · Sequelize · MySQL · Redis · Zod · Provider classes |
| Frontend | `frontend/CLAUDE.md` | Vue 3 SPA · Vite · Vuex · Tailwind · Transactional portal (bemovil.net) |
| Admin | `admin/CLAUDE.md` | Vue 3 SPA · Internal portal → BeOne CRM/ERP |
| Proxy | `bemovil2-proxy/CLAUDE.md` | Reverse proxy · Green-Blue deployments · Cron jobs · Axiom telemetry |

## Project-Level Skill Routing

| Context Pattern | Skill | Trigger |
|----------------|-------|---------|
| `e2e.test.ts`, API test creation/update/audit | `e2e-forge` | E2E tests for backend endpoints. Uses Axiom logs + CREA + TDD loops |
| `doc.md`, endpoint documentation | `e2e-forge` (Mode 4: DOCUMENT) | Endpoint documentation generation |
| OLD routes (express-validator + middleware) | `migration-agent` | Migrate to NEW pattern (Zod + helpers). See `context/guidelines.md` Section 2 |

## Team Knowledge Sharing — Proposals

When the user says **"FEEDBACK DE USO"** or **"DESCUBRIMIENTO"**, follow this exact workflow:

### 1. Guide the user

- **FEEDBACK DE USO** → Read `feedback/FEEDBACK_TEMPLATE.md` and walk the user through each section (problem, context, expected vs actual, proposed solution, priority).
- **DESCUBRIMIENTO** → Read `feedback/DISCOVERY_TEMPLATE.md` and walk the user through each section (what was discovered, which context file it affects, proposed change as a prompt, evidence, impact).

### 2. Build the proposal file

Create a single `.md` file with the filled-out template. The file name format is:

```
proposals/{github-username}-{short-slug}.md
```

Example: `proposals/juandev-sirse-timeout-15s.md`

### 3. Determine the target repo

| What changed / is affected | Target repo |
|----------------------------|-------------|
| autoSDD pipeline, skills, orchestrator behavior | `thestark77/autosdd` |
| E2E Forge modes, Axiom queries, test patterns | `thestark77/e2e-forge` |
| Project context (business_logic, guidelines), installer, templates, agents | `IT-Bemovil/be-code-kit` |

### 4. Create the PR

```bash
# Clone target repo to a temp dir
git clone https://github.com/{target-repo}.git /tmp/{repo-name}
cd /tmp/{repo-name}

# Create branch and add the proposal file
git checkout -b proposal/{github-username}-{short-slug}
cp {proposal-file} proposals/
git add proposals/
git commit -m "proposal: {short description}"
git push -u origin proposal/{github-username}-{short-slug}

# Create PR
gh pr create --title "Proposal: {short description}" --body "$(cat <<'EOF'
## Tipo
- [ ] FEEDBACK DE USO — problema o mejora de herramientas
- [ ] DESCUBRIMIENTO — conocimiento del proyecto

## Resumen
{1-2 sentences}

Propuesto por @{github-username}
EOF
)"
```

### 5. Share the PR URL with the user

The proposal file is the ONLY change in the PR. No code modifications. When the team merges the PR, the `.md` file gets added to the `proposals/` folder as a record.

## Agent Operational Freedom

- **LOCAL database is yours**: create, read, update, delete data freely
- **Start dev server** and test features via Playwright or curl
- **Ask before guessing**: If clarifying questions would significantly increase success, ASK FIRST
- **Suggest improvements**: Proactively propose enhancements
- **Read sub-project CLAUDE.md**: Always read the relevant sub-project conventions before coding
- **Request additional context proactively**: At any point — especially BEFORE starting a task — ask the user for examples of logs, database records, API responses, screenshots, or any other context that would help you deliver excellent results. The user prefers providing context upfront over fixing misunderstandings later

## Mandatory Conventions

### Endpoint Documentation (`doc.md`)

Every time a backend endpoint is **created or modified**, the agent MUST generate or update the corresponding `doc.md` using `e2e-forge` (Mode 4: DOCUMENT).

- **Location**: `backend/app/{domain}/{feature}/doc.md` (sibling to `route.ts`)
- **Trigger**: Any change to `route.ts`, validators, helpers, or response shape of an endpoint
- **How**: Use `/e2e-forge` in DOCUMENT mode, or delegate to a sub-agent with `e2e-forge` skill injection
- **No exceptions**: Even small changes (new field, renamed error code) require a doc.md update

**Required analysis** (same pipeline as e2e-forge Mode 4):

| Step | What | Why |
|------|------|-----|
| Code analysis | Read `route.ts`, trace validators, imports, helpers, models | Understand all inputs, outputs, error codes |
| Frontend tracing | Run `frontend-tracer.ts` to find all `postRequest()` calls in frontend + admin | Document all consumers |
| Backend tracing | Grep for endpoint path in other routes, cron jobs, webhooks | Discover internal callers |
| Axiom extraction | Query `bemovil2` + `errors` datasets for production traffic | Add real usage stats, error rates, response times |
| Dependency mapping | List every model, helper, config, and external provider used | Complete dependency graph in doc.md |

## autoSDD v5.3 — Active Pipeline (DO NOT REMOVE)

ALL prompts go through autoSDD unless `[raw]`, `[no-sdd]`, or `skip autosdd`.

### Core Rules
1. **DELEGATE** — never write 2+ files inline. Read SKILL.md Section 1.
2. **VERSION FIRST** — before planning, create `context/appVersions/vX.Y.Z/` + save `original_prompt.md`
3. **PROGRESS.md is sacred** — update at every step. It's your compaction survival anchor.
4. **Feedback after every task** — ask user ≥1 strategic question. Persist answers.

### Pipeline
`VERSION INIT → TRIAGE → ROUTE → PLAN (CREA) → DELEGATE → COLLECT → CLOSE → KNOWLEDGE UPDATE`

### Routing (if X → use Y skill)
| Context | Skill |
|---------|-------|
| Public UI (.tsx/.vue pages) | `frontend-design` |
| Admin/dashboard UI | `interface-design` |
| API routes, validation | `error-handling-patterns` |
| DB schema, .prisma | `postgresql-table-design` |
| Tests (.test., .spec.) | `e2e-testing-patterns` |
| Browser automation | `playwright-cli` (ALWAYS --headed) |
| PR creation | `branch-pr` |
| Security, 5+ files | `judgment-day` |

**Screenshots**: ALL Playwright captures → `context/appVersions/vX.Y.Z/screenshots/` (current version). Never elsewhere.

### Knowledge Caching (saves tokens)
Before reading 4+ files → check Engram `knowledge/{project}/{topic}` for cached maps.
After understanding a flow → save a 20-line map to Engram.

### Compaction Recovery (read this AFTER any compaction)
1. Read `PROGRESS.md` (your state anchor)
2. Read current version's `prompt.md`
3. `mem_context()` + `mem_search("session/{project}")`
4. Resume from where PROGRESS.md says

### Hooks
- **SubagentStop**: Update PROGRESS.md + save observation + check feedback debt
- **PreCompact**: Save ALL state to PROGRESS.md + Engram NOW (compaction imminent)
- **Stop**: Check feedback.md generated + PROGRESS.md current
- **UserPromptSubmit**: Reset stop-hook debounce

### gentle-ai (optional foundation)
Provides: Engram MCP · SDD phases · persona · model-assignments · branch-pr · judgment-day
autoSDD works without it (degraded mode).

Read full framework: `~/.claude/skills/autosdd/SKILL.md`
