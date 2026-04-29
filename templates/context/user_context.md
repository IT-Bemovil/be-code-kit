# User Context — [TU NOMBRE]

> **Propósito**: Documento vivo que describe quién sos, cómo trabajás, qué preferís, y cómo colaborar contigo de forma efectiva. Personalizá las secciones marcadas con [COMPLETAR].

---

## Identity

- **Name**: [TU NOMBRE COMPLETO]
- **Email**: [TU EMAIL]
- **Location**: Colombia
- **Timezone**: America/Bogota (UTC-5)
- **GitHub**: [TU USUARIO DE GITHUB]

## Roles

- **Developer at Bemovil** — Parte del equipo de 5 desarrolladores
- **Areas**: [COMPLETAR — Frontend / Backend / Admin / Full-stack]
- **Direct report**: Sebastián Flórez (Tech Lead)

## Technical Expertise

- **Backend**: Node.js, Express 5, TypeScript, Sequelize ORM, MySQL, Redis
- **Frontend**: Vue.js 3, Vite, Vuex, Vue Router, Tailwind CSS
- **Infrastructure**: AWS (S3, EC2), GitHub Actions CI/CD
- **AI/Dev Tools**: Claude Code, autoSDD v5.3, Engram memory
- [COMPLETAR — agrega o quita según tu experiencia real]

## Team & Organization

### Team Distribution
- **5 developers** — todos cross-functional (frontend, admin, backend)
- Todos tienen acceso a los 3 repos principales: frontend, admin, backend
- **Proxy access es restringido** a desarrolladores selectos

### Methodology
- **Kanban**: Recibir requests/problemas → refinar en requerimientos IT → priorizar por impacto comercial → desarrollar y desplegar ASAP
- **Tool**: Linear para gestión de tareas

### Development Workflow (Branching)
```
1. Recibir asignación de issue en Linear
2. Claude Code (con Linear MCP) toma contexto del issue → hace preguntas
3. Crear feature branch (nombre de Linear, e.g., BEM-374)
4. Desarrollar y testear localmente
5. PR/merge a sandbox → auto-deploy a sandbox.bemovil.net
6. Testear en sandbox
7. PR desde feature branch (NO sandbox) → main o master
8. Code review por Tech Lead + jefe de área para tareas críticas
9. Merge a main/master
10. Tech Lead crea GitHub Release → dispara deployment
```

### Release Control
- **El Tech Lead controla todos los releases**: frontend, backend, proxy, admin deployments
- Tags: `v1.2.3` → Production, `v1.2.3-beta` → Sandbox

## Working Style

- [COMPLETAR — describí cómo preferís trabajar con la IA]
- Ejemplo: "Doy contexto extenso y espero que la IA lo retenga"
- Ejemplo: "Prefiero respuestas cortas y directas"
- Ejemplo: "Me gusta entender el WHY, no solo el WHAT"

## Communication Preferences

- **Language**: Spanish para conversación, English para código
- **Response style**: [COMPLETAR — preferís respuestas detalladas o concisas?]
- **Depth**: [COMPLETAR — te gustan explicaciones técnicas profundas?]

## Plan & Hardware

- **AI Plan**: [COMPLETAR — Claude Pro / Claude Max]
- **OS**: [COMPLETAR — Windows / macOS / Linux]
- **Shell**: [COMPLETAR — Bash / PowerShell / Zsh]
- **Package Manager**: pnpm
- **Editor**: Claude Code CLI

## Key Preferences

- NEVER add "Co-Authored-By" or AI attribution to commits — conventional commits only
- NEVER build after changes
- Use bat/rg/fd/sd/eza — NEVER cat/grep/find/sed/ls
- Always prefix commands with `rtk` for token optimization
- TypeScript strict, `interface` over `type`, no `any`
- Zod validation on EVERY endpoint with error codes (not text)
- Code in English, UI in Spanish (neutral Colombian)
- When asking a question, STOP and wait — never continue or assume answers
- Verify technical claims before stating them

---

*Personalizado por: [TU NOMBRE] — [FECHA]*
