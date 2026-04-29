<p align="center">
  <img src="https://img.shields.io/badge/be--code--kit-v1.0-blue?style=for-the-badge" alt="version" />
  <img src="https://img.shields.io/badge/autoSDD-v5.3-green?style=for-the-badge" alt="autoSDD" />
  <img src="https://img.shields.io/badge/skills-16%2B-purple?style=for-the-badge" alt="skills" />
  <img src="https://img.shields.io/badge/plugins-5-orange?style=for-the-badge" alt="plugins" />
</p>

<h1 align="center">be-code-kit</h1>

<p align="center">
  <strong>El entorno de desarrollo con IA del equipo Bemovil, listo para instalar en un solo comando.</strong><br/>
  Creado por el Tech Lead para replicar su setup exacto de Claude Code en las máquinas de todo el equipo.
</p>

<p align="center">
  <a href="#-instalación">Instalación</a> · <a href="#-qué-incluye">Qué incluye</a> · <a href="#-post-instalación">Post-instalación</a> · <a href="#-cómo-usar-claude-code">Uso diario</a> · <a href="#-troubleshooting">Troubleshooting</a>
</p>

---

## 📑 Tabla de Contenido

- [Qué es be-code-kit](#-qué-es-be-code-kit)
- [Requisitos previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Qué hace el instalador (paso a paso)](#-qué-hace-el-instalador-paso-a-paso)
- [Post-instalación](#-post-instalación)
- [Estructura del proyecto resultante](#-estructura-del-proyecto-resultante)
- [Variables de entorno](#-variables-de-entorno)
- [Lo que queda instalado](#-lo-que-queda-instalado)
  - [autoSDD v5.3](#autosdd-v53)
  - [E2E Forge](#e2e-forge)
  - [Skills (16+)](#skills-instaladas-17)
  - [Plugins (5)](#plugins-instalados-5)
- [Captura de audio con IA (SuperWhisper)](#-captura-de-audio-con-ia-superwhisper)
- [Sistema de Feedback Participativo](#-sistema-de-feedback-participativo)
  - [Feedback de Herramientas](#1-feedback-de-herramientas--feedback-de-uso)
  - [Descubrimientos del Proyecto](#2-descubrimientos-del-proyecto--descubrimiento)
- [Cómo usar Claude Code con este setup](#-cómo-usar-claude-code-con-este-setup)
- [Comandos útiles de referencia](#-comandos-útiles-de-referencia)
- [Troubleshooting](#-troubleshooting)
- [Proyectos relacionados](#-proyectos-relacionados)
- [Contributing / Feedback](#-contributing--feedback)
- [Licencia](#-licencia)

---

## 🎯 Qué es be-code-kit

**be-code-kit** es un instalador automatizado que replica el entorno completo de desarrollo con IA del Tech Lead de Bemovil 2.0 en tu máquina. En un solo comando vas a tener:

- **autoSDD v5.3** — Framework de desarrollo autónomo que orquesta sub-agentes de IA
- **E2E Forge** — Skill personalizada para tests E2E automatizados con logs reales de Axiom
- **16+ skills de desarrollo** — Desde prompt engineering hasta diseño de interfaces
- **5 plugins de Claude Code** — Powerline, Engram, code review, y más
- **Engram MCP** — Memoria persistente entre sesiones
- **Contexto completo del proyecto** — Business logic, guidelines, convenciones, agentes especializados
- **4 repositorios clonados** — Backend, Frontend, Admin, y Proxy de Bemovil 2.0

Existen dos versiones del kit:

| Kit | Repo | Descripción |
|-----|------|-------------|
| **be-code-kit** | [thestark77/be-code-kit](https://github.com/thestark77/be-code-kit) | Versión completa con contexto Bemovil (esta) |
| **stark-kit** | [thestark77/stark-kit](https://github.com/thestark77/stark-kit) | Versión genérica — solo framework, sin contexto empresarial |

> 💡 Si sos externo a Bemovil o querés usar el framework en otro proyecto, usá **stark-kit**.

---

## ✅ Requisitos previos

Antes de ejecutar el instalador, necesitás tener estas herramientas instaladas. Si te falta alguna, hacé clic en el enlace para descargarla.

| # | Requisito | Verificación | Descarga |
|---|-----------|-------------|----------|
| 1 | **Node.js 18+** | `node --version` | [nodejs.org](https://nodejs.org) |
| 2 | **Git** | `git --version` | [git-scm.com/downloads](https://git-scm.com/downloads) |
| 3 | **Claude Code CLI** | `claude --version` | `npm install -g @anthropic-ai/claude-code` |
| 4 | **pnpm** (recomendado) | `pnpm --version` | `npm install -g pnpm` |
| 5 | **Acceso a GitHub** | — | Necesitás acceso a la org [IT-Bemovil](https://github.com/IT-Bemovil) |
| 6 | **Playwright** (opcional) | — | `npx playwright install` (después de la instalación) |

### Sobre Claude Code CLI

Claude Code requiere un **plan Claude Pro ($20 USD/mes)**. La empresa cubre este costo — si no tenés acceso aún, pedíselo al Tech Lead.

```bash
# Instalar Claude Code CLI globalmente
npm install -g @anthropic-ai/claude-code

# Verificar instalación
claude --version

# Primera vez: te va a pedir autenticarte con tu cuenta de Anthropic
claude
```

### Sobre el acceso a GitHub

Los repos de Bemovil están en la organización **IT-Bemovil** en GitHub. Si no tenés acceso, el instalador va a saltar los repos que no pueda clonar (no se rompe), pero necesitás pedirle al Tech Lead que te agregue a la organización.

---

## 📦 Instalación

### Linux / macOS / WSL / Git Bash

```bash
git clone https://github.com/thestark77/be-code-kit.git
cd be-code-kit
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/thestark77/be-code-kit.git
cd be-code-kit
.\install.ps1
```

### Directorio de destino personalizado

Por defecto el instalador crea la carpeta `Bemovil2.0/` en el mismo nivel donde clonaste `be-code-kit`. Podés especificar otro directorio:

```bash
bash install.sh /ruta/a/mi/directorio
```

> ⚠️ Si el directorio ya existe y tiene archivos, el instalador te pregunta si querés **actualizar** — solo sobreescribe archivos de configuración (CLAUDE.md, context/, .claude/) sin tocar los repositorios existentes.

---

## 🔧 Qué hace el instalador (paso a paso)

El instalador ejecuta **8 pasos** en secuencia. Acá te explicamos cada uno para que sepas exactamente qué está pasando en tu máquina:

<details>
<summary><strong>Paso 0 — Verifica requisitos</strong></summary>

Chequea que tengas instalados:
- `git` — control de versiones
- `claude` — Claude Code CLI (la interfaz de IA)
- `npm` o `pnpm` — gestor de paquetes de Node.js

Si falta alguno, el instalador se detiene y te indica cómo instalarlo.
</details>

<details>
<summary><strong>Paso 1 — Prepara el directorio de destino</strong></summary>

- Valida si el directorio existe y si tiene contenido
- Si está vacío, lo crea sin preguntar
- Si ya tiene archivos, te pregunta si querés continuar en **modo actualización** (solo sobreescribe configs, no toca repos)
</details>

<details>
<summary><strong>Paso 2 — Copia archivos de configuración</strong></summary>

Copia desde `templates/` al directorio destino:
- `CLAUDE.md` — Configuración principal de la IA, define agentes, routing de skills, convenciones
- `AGENTS.md` — Definiciones detalladas de cada agente especializado (backend-dev, frontend-dev, etc.)
- `PROGRESS.md` — Estado del desarrollo, lo usa autoSDD para sobrevivir compactaciones
- `.gitignore` — Ignora node_modules, .env, builds, etc.
- `.claude/settings.json` — Hooks y permisos del proyecto
- `context/guidelines.md` — Convenciones técnicas no negociables
- `context/business_logic.md` — Lógica de negocio y dominio de Bemovil
- `context/user_context.md` — Tu perfil de desarrollador (personalizable)
- `context/Bemovil2questions.md` — Preguntas pendientes del proyecto
</details>

<details>
<summary><strong>Paso 3 — Crea plantillas de .env vacías</strong></summary>

Crea archivos `.env` con comentarios explicativos pero sin valores sensibles en cada sub-proyecto. Más adelante vas a pegar los valores reales que te comparte el Tech Lead.
</details>

<details>
<summary><strong>Paso 4 — Clona los 4 repositorios</strong></summary>

Clona desde la org IT-Bemovil de GitHub:

| Repo | URL | Branch |
|------|-----|--------|
| backend | `IT-Bemovil/bemovil2.0-backend` | `master` |
| frontend | `IT-Bemovil/bemovil2.0-frontend` | `main` |
| admin | `IT-Bemovil/bemovil2.0-frontend-admin` | `main` |
| bemovil2-proxy | `IT-Bemovil/bemovil2-proxy` | `main` |

> Si algún repo falla por falta de permisos, **se salta sin detener la instalación**. Te aparece una advertencia al final.
</details>

<details>
<summary><strong>Paso 5 — Instala autoSDD v5.3</strong></summary>

Descarga y ejecuta el instalador interactivo de autoSDD. Este paso abre un menú donde debés seleccionar al menos **"claude-code"** como agente destino.

autoSDD instala automáticamente:
- Skills compartidas (prompt-engineering, error-handling, etc.)
- Engram MCP (memoria persistente)
- Protocolos compartidos (RTK, persona, model-assignments)
</details>

<details>
<summary><strong>Paso 6 — Instala E2E Forge</strong></summary>

Clona el repo de [E2E Forge](https://github.com/thestark77/e2e-forge) y ejecuta su instalador. Queda disponible como skill en Claude Code bajo el comando `/e2e-forge`.
</details>

<details>
<summary><strong>Paso 7 — Instala skills y plugins adicionales</strong></summary>

Instala skills que autoSDD no incluye por defecto:
- Caveman (comunicación ultra-comprimida)
- Vercel React best practices
- shadcn component management
- SDD Agent Team (branch-pr, judgment-day)
- David Castagneto skills

Y los 5 plugins de Claude Code (powerline, engram, frontend-design, code-review, code-simplifier).
</details>

<details>
<summary><strong>Paso 8 — Inicializa repositorio raíz</strong></summary>

Inicializa un repo Git en la carpeta raíz (`Bemovil2.0/`) con los archivos de configuración, y crea la carpeta `context/appVersions/v0.1.0/` para el versionado de autoSDD.
</details>

---

## 🚀 Post-instalación

Después de que el instalador termine, necesitás completar estos pasos manualmente:

### 1. Pegar variables de entorno (.env)

El Tech Lead te comparte las variables de entorno por chat interno. Cada sub-proyecto tiene su propio `.env`:

```bash
# Pegar los valores en cada archivo .env
# (El instalador ya creó las plantillas vacías)

backend/.env        # 76+ variables — DB, APIs, proveedores
frontend/.env       # VITE_* variables — Blokay, URLs
admin/.env          # Similar a frontend
bemovil2-proxy/.env # Orchestrator, Axiom
```

> ⚠️ **NUNCA** hagas commit de archivos `.env` — ya están en `.gitignore`. Si ves un `.env` staged, quitalo inmediatamente.

### 2. Instalar dependencias de cada proyecto

```bash
cd backend && pnpm install
cd ../frontend && pnpm install
cd ../admin && pnpm install
cd ../bemovil2-proxy && pnpm install
```

### 3. Configurar Axiom (para E2E Forge)

Pedile al Tech Lead el `AXIOM_QUERY_TOKEN` y pegalo en `backend/.env`. Sin esto, E2E Forge no puede extraer logs de producción.

### 4. Instalar Playwright (para tests de browser)

```bash
npx playwright install chromium
```

### 5. Verificar la instalación

```bash
cd Bemovil2.0
claude
# Debería arrancar Claude Code con autoSDD activo
# Probá con: "¿qué skills tengo disponibles?"
```

---

## 🗂 Estructura del proyecto resultante

Después de la instalación, tu directorio `Bemovil2.0/` va a lucir así:

```
Bemovil2.0/
├── CLAUDE.md                      # Configuración principal de IA
├── AGENTS.md                      # Definiciones de agentes especializados
├── PROGRESS.md                    # Estado del desarrollo (autoSDD)
├── .gitignore                     # Ignora .env, node_modules, builds
│
├── .claude/
│   └── settings.json              # Hooks y permisos del proyecto
│
├── context/
│   ├── guidelines.md              # Convenciones técnicas (stack, patrones, seguridad)
│   ├── business_logic.md          # Lógica de negocio y dominio
│   ├── user_context.md            # Tu perfil de desarrollador (personalizable)
│   ├── Bemovil2questions.md       # Preguntas pendientes
│   ├── blokayExample.md           # Ejemplo de reportes Blokay
│   └── appVersions/               # Versiones de desarrollo (autoSDD)
│       └── v0.1.0/                # Primera versión
│
├── backend/                       # Express 5 API — TypeScript, Sequelize, MySQL
│   ├── CLAUDE.md                  # Convenciones del backend
│   ├── .env                       # Variables de entorno (no commitear)
│   └── ...
│
├── frontend/                      # Vue 3 — Portal transaccional (bemovil.net)
│   ├── CLAUDE.md                  # Convenciones del frontend
│   ├── .env                       # Variables VITE_*
│   └── ...
│
├── admin/                         # Vue 3 — Portal interno → BeOne CRM/ERP
│   ├── CLAUDE.md                  # Convenciones del admin
│   ├── .env                       # Variables VITE_*
│   └── ...
│
├── feedback/                      # Templates para el sistema de proposals
│   ├── FEEDBACK_TEMPLATE.md       # Plantilla para problemas con herramientas
│   └── DISCOVERY_TEMPLATE.md      # Plantilla para descubrimientos del proyecto
│
├── proposals/                     # PRs mergeadas quedan acá como registro
│
└── bemovil2-proxy/                # Reverse proxy + Green-Blue deployments
    ├── CLAUDE.md                  # Convenciones del proxy
    ├── .env                       # Orchestrator, Axiom
    └── ...
```

---

## 🔐 Variables de entorno

### Filosofía

Cada sub-proyecto maneja sus propias variables de entorno en un archivo `.env` local. El instalador crea plantillas vacías con comentarios. Las credenciales reales las comparte el Tech Lead por canal privado.

### Reglas de oro

- ❌ **NUNCA** commitear archivos `.env`
- ❌ **NUNCA** pegar credenciales de producción en tu máquina local
- ✅ Siempre usar credenciales de **sandbox** para desarrollo
- ✅ Si necesitás una variable nueva, pedísela al Tech Lead

### Desglose por sub-proyecto

<details>
<summary><strong>backend/.env — 76+ variables</strong></summary>

| Categoría | Variables | Descripción |
|-----------|-----------|-------------|
| **Database (write)** | `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`, `DB_PORT` | MySQL principal (escritura) |
| **Database (read)** | `DB_READ_HOST`, `DB_READ_USER`, etc. | Réplica de lectura |
| **Bepay** | `BEPAY_API_URL`, `BEPAY_API_KEY`, `BEPAY_SECRET` | Pasarela de pagos integrada |
| **SMS** | `SMS_API_URL`, `SMS_API_KEY` | Envío de SMS transaccionales |
| **AWS** | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET` | Almacenamiento S3 |
| **Blokay** | `BLOKAY_API_KEY`, `BLOKAY_WORKSPACE` | Reportes parametrizados |
| **Email** | `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS` | Emails transaccionales |
| **Sirse SOAP** | `SIRSE_URL`, `SIRSE_USER`, `SIRSE_PASS` | Integración SOAP con Sirse |
| **WhatsApp** | `WHATSAPP_API_URL`, `WHATSAPP_TOKEN` | Notificaciones WhatsApp |
| **Security** | `JWT_SECRET`, `JWT_REFRESH_SECRET`, `ENCRYPTION_KEY` | Autenticación y cifrado |
| **KYC** | `KYC_API_URL`, `KYC_API_KEY` | Verificación de identidad |
| **Anthropic AI** | `ANTHROPIC_API_KEY` | IA para validación inteligente |
| **Bank integrations** | `BANK_*` variables | Integraciones bancarias |
| **Axiom** | `AXIOM_TOKEN`, `AXIOM_DATASET`, `AXIOM_QUERY_TOKEN` | Logging centralizado |

</details>

<details>
<summary><strong>frontend/.env</strong></summary>

| Variable | Descripción |
|----------|-------------|
| `VITE_APP_BASE_URL` | URL base de la API (sandbox o producción) |
| `VITE_BLOKAY_API_KEY` | API key de Blokay para reportes |
| `VITE_BLOKAY_WORKSPACE` | Workspace de Blokay |

</details>

<details>
<summary><strong>admin/.env</strong></summary>

| Variable | Descripción |
|----------|-------------|
| `VITE_APP_BASE_URL` | URL base de la API |
| `VITE_BLOKAY_API_KEY` | API key de Blokay |
| `VITE_BLOKAY_WORKSPACE` | Workspace de Blokay |

> Estructura similar a frontend, pero puede tener variables adicionales para features internas de BeOne.

</details>

<details>
<summary><strong>bemovil2-proxy/.env</strong></summary>

| Variable | Descripción |
|----------|-------------|
| `ORCHESTRATOR_*` | Configuración de Green-Blue deployments |
| `AXIOM_TOKEN` | Token para forwarding de logs a Axiom |
| `AXIOM_DATASET` | Dataset de destino en Axiom |

</details>

---

## 🧰 Lo que queda instalado

### autoSDD v5.3

**Framework de desarrollo autónomo** que transforma a Claude Code en un orquestador inteligente que delega trabajo a sub-agentes especializados.

| Aspecto | Detalle |
|---------|---------|
| **Repo** | [github.com/thestark77/autosdd](https://github.com/thestark77/autosdd) |
| **Versión** | 5.3 |
| **Ubicación** | `~/.claude/skills/autosdd/SKILL.md` |
| **Activación** | Automática en cada conversación de Claude Code |
| **Desactivación** | Prefijá tu mensaje con `[raw]`, `[no-sdd]`, o `skip autosdd` |

#### Pipeline de autoSDD

```
VERSION INIT → TRIAGE → ROUTE → PLAN (CREA) → DELEGATE → COLLECT → CLOSE → KNOWLEDGE UPDATE
```

1. **VERSION INIT** — Crea `context/appVersions/vX.Y.Z/` y guarda el prompt original
2. **TRIAGE** — Clasifica la complejidad de la tarea
3. **ROUTE** — Selecciona el skill apropiado según el contexto
4. **PLAN (CREA)** — Crea un `prompt.md` estructurado con Contexto, Requisitos, Especificaciones, Acción
5. **DELEGATE** — Lanza sub-agentes con skill injection (el orquestador **nunca** escribe código directamente)
6. **COLLECT** — Recoge resultados de los sub-agentes
7. **CLOSE** — Cierra la versión con changelog
8. **KNOWLEDGE UPDATE** — Actualiza Engram con lo aprendido

#### Regla fundamental

> **El orquestador DELEGA. Nunca escribe código fuente directamente.** Si ves que Claude escribe más de 2 archivos inline, algo está mal.

---

### E2E Forge

**Skill personalizada** para crear tests E2E automatizados conectados con logs de producción reales.

| Aspecto | Detalle |
|---------|---------|
| **Repo** | [github.com/thestark77/e2e-forge](https://github.com/thestark77/e2e-forge) |
| **Ubicación** | `~/.claude/skills/e2e-forge/` |
| **Uso** | Escribí `/e2e-forge` en tu sesión de Claude Code |
| **Requisito** | `AXIOM_QUERY_TOKEN` configurado en `backend/.env` |

#### Modos de operación

| Modo | Comando | Descripción |
|------|---------|-------------|
| **CREATE** | `/e2e-forge` | Crea tests E2E nuevos para un endpoint |
| **UPDATE** | `/e2e-forge` (sobre test existente) | Actualiza tests existentes con nuevos escenarios |
| **BATCH** | `/e2e-forge` (múltiples endpoints) | Genera tests para múltiples endpoints a la vez |
| **DOCUMENT** | `/e2e-forge` (mode: DOCUMENT) | Genera `doc.md` con documentación completa del endpoint |

#### Qué lo hace especial

- Conecta con **Axiom** para extraer logs de producción reales
- Genera tests basados en **tráfico real**, no mocks inventados
- Incluye tracing de consumidores frontend y backend
- Los tests corren contra la **base de datos real** (SSH tunnel)

---

### Skills instaladas (16+)

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `prompt-engineering-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | Patrones avanzados de prompting para LLMs |
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) | Interfaces frontend production-grade |
| `interface-design` | [dammyjay93/interface-design](https://github.com/dammyjay93/interface-design) | Diseño de dashboards y paneles admin |
| `error-handling-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | Patrones de manejo de errores multi-lenguaje |
| `e2e-testing-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | Testing E2E con Playwright/Cypress |
| `playwright-cli` | [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) | Automatización de browser |
| `claude-md-improver` | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Auditoría y mejora de archivos CLAUDE.md |
| `branch-pr` | [gentleman-programming/sdd-agent-team](https://github.com/gentleman-programming/sdd-agent-team) | Workflow de creación de PRs |
| `judgment-day` | [gentleman-programming/sdd-agent-team](https://github.com/gentleman-programming/sdd-agent-team) | Code review adversarial paralelo |
| `caveman` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Comunicación ultra-comprimida (ahorra tokens) |
| `caveman-review` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Code review comprimido |
| `compress` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Compresión de archivos de memoria |
| `vercel-react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Patrones de React/Next.js de Vercel |
| `postgresql-table-design` | [wshobson/agents](https://github.com/wshobson/agents) | Diseño de esquemas PostgreSQL |
| `shadcn` | [shadcn-ui/ui](https://github.com/shadcn-ui/ui) | Gestión de componentes shadcn |
| `skill-creator` | autoSDD | Creación de nuevas skills |
| `knowledge-graph` | autoSDD | Grafos de conocimiento visuales |
| `feedback-report` | autoSDD | Reportes de feedback y calidad |

---

### Plugins instalados (5)

| Plugin | Descripción |
|--------|-------------|
| **claude-powerline** | Status line visual en la terminal — muestra branch, modelo, tokens |
| **engram** | Memoria persistente MCP — recuerda decisiones, convenciones, bugs entre sesiones |
| **frontend-design** | Plugin de diseño UI — genera interfaces de alta calidad |
| **code-review** | Review de código automatizado sobre PRs |
| **code-simplifier** | Simplificación y refactoring de código |

---

## 🎙 Captura de audio con IA (SuperWhisper)

Una de las herramientas más potentes del workflow no es código — es **hablarle a la IA en vez de escribir**. Es mucho más rápido dictar un prompt complejo que tipearlo, especialmente cuando necesitás explicar contexto de negocio.

### Recomendación: SuperWhisper

[SuperWhisper](https://superwhisper.com) es una app de escritorio que captura tu voz y la convierte en texto formateado usando IA. Funciona a nivel del sistema — no solo para código, sino también para mensajes, emails, documentación.

| Aspecto | Detalle |
|---------|---------|
| **Plataformas** | macOS, Windows |
| **Precio** | ~$5 USD/mes con descuento estudiantil (~20,000 COP/mes) |
| **Descarga** | [superwhisper.com](https://superwhisper.com) |
| **Función** | Dictar → IA limpia el texto → se pega automáticamente |

#### Configuración paso a paso

1. **Descargá e instalá** SuperWhisper desde [superwhisper.com](https://superwhisper.com)
2. **Creá un modo personalizado** para español
3. **Pegá el prompt de formateo** (ver sección siguiente)
4. **Seleccioná el modelo** — recomiendo Whisper local para velocidad, o API para máxima calidad
5. **Configurá el atajo de teclado** — recomendado: `Ctrl+Shift+Space` o similar
6. **Probá** con un mensaje de voz corto

#### Qué hace SuperWhisper por vos

- ✅ Elimina muletillas ("eh", "este", "o sea")
- ✅ Formatea el texto correctamente (puntuación, párrafos)
- ✅ Aplica correcciones ortográficas
- ✅ Funciona en cualquier app del sistema (Slack, VS Code, browser, terminal)

### Alternativa gratuita: ChatGPT / Claude por voz

Si no tenés licencia de SuperWhisper, podés usar cualquier chat con IA que tenga input de voz:

1. Abrí **ChatGPT** (recomendado — mejor reconocimiento de voz) o **Claude** en el browser
2. Creá una conversación nueva
3. Pegá el **prompt de formateo** (abajo)
4. Usá el botón de **input de voz** para dictar
5. La IA va a formatear y limpiar tu texto
6. Copiá el resultado y pegalo donde lo necesités

> 💡 **ChatGPT 5.2** es la opción recomendada — rápido, barato, incluso tiene plan gratuito.

### Prompt de formateo de audio (español)

Copiá y pegá este prompt completo en SuperWhisper (como modo personalizado) o en un chat de IA:

<details>
<summary><strong>Click para ver el prompt completo</strong></summary>

```
# Prompt en español (USAR SOLO PARA TEXTO EN ESPAÑOL)

## ROL
Eres un asistente de transcripción de voz profesional. Tu única función es tomar audio dictado en español y convertirlo en texto limpio, bien puntuado y correctamente formateado.

## REGLAS ABSOLUTAS

1. **Solo formatear** — NO respondas, NO comentes, NO agregues información. Solo devuelve el texto limpio.
2. **Mantener el contenido exacto** — No cambies el significado, no agregues ni quites ideas.
3. **Corregir errores de dictado** — Arregla muletillas, repeticiones, falsos inicios ("eh", "este", "o sea", "digamos").
4. **Puntuación correcta** — Agrega puntos, comas, signos de interrogación/exclamación donde corresponda.
5. **Párrafos naturales** — Separa en párrafos cuando hay cambio de tema o pausa larga.
6. **Español neutro** — Mantener el estilo del hablante, pero corregir errores gramaticales evidentes.
7. **Términos técnicos** — Si detectas términos de programación/tecnología, escríbelos correctamente (TypeScript, no "tai script"; API, no "a pe i").
8. **NO usar markdown** salvo que el hablante lo pida explícitamente.
9. **NO agregar títulos ni encabezados** salvo que el hablante los dicte.
10. **Si el audio es una instrucción para IA** (prompt, tarea, request), formatearlo como tal pero sin ejecutarlo.

## FORMATO DE SALIDA

- Texto limpio, sin comillas envolventes
- Un párrafo por idea principal
- Sin bullet points salvo que el hablante los dicte
- Sin emojis salvo que el hablante los mencione
```

</details>

---

## 🔄 Sistema de Feedback Participativo

El kit incluye **dos sistemas** para que todo el equipo contribuya al proyecto. Cada sesión individual con la IA genera conocimiento que debería ser patrimonio de todos.

### Cómo funciona

Ambos flujos funcionan igual: la IA te guía para crear un **archivo `.md`** con tu feedback o descubrimiento, y lo sube como PR al repo correspondiente. Ese archivo va a la carpeta `proposals/` con tu nombre de GitHub.

**La PR contiene SOLO ese archivo** — no modifica código ni configuración. El equipo revisa, vota, y cuando se aprueba, queda como registro permanente y se aplica al proyecto.

### 1. Feedback de Herramientas — "FEEDBACK DE USO"

Para reportar problemas o mejoras sobre las herramientas de IA (skills, plugins, configuración).

**Flujo:**

1. **Escribí "FEEDBACK DE USO"** en tu sesión de Claude Code
2. **La IA te guía** por la plantilla (`feedback/FEEDBACK_TEMPLATE.md`)
3. **Se genera un archivo** `proposals/{tu-github}-{descripcion-corta}.md`
4. **Se crea una PR** en el repo que corresponda:

| Afecta a... | PR va a... |
|-------------|-----------|
| autoSDD, skills, orquestador | `thestark77/autosdd` |
| E2E Forge, tests, Axiom | `thestark77/e2e-forge` |
| Installer, templates, contexto | `thestark77/be-code-kit` |

5. **El equipo revisa y vota** en la PR

### 2. Descubrimientos del Proyecto — "DESCUBRIMIENTO"

Acá está la magia del trabajo colectivo con IA. Cada desarrollador, en sus sesiones diarias, **descubre cosas sobre el proyecto** que no estaban documentadas:

- Lógica de negocio oculta en el código
- Funciones específicas que nadie sabía que existían
- Relaciones entre sistemas que no son obvias
- Convenciones no documentadas
- Gotchas que te costaron tiempo

**Flujo:**

1. **Escribí "DESCUBRIMIENTO"** en tu sesión de Claude Code
2. **La IA te guía** por la plantilla (`feedback/DISCOVERY_TEMPLATE.md`)
3. **Se genera un archivo** `proposals/{tu-github}-{descripcion-corta}.md` que incluye:
   - Qué se descubrió
   - Qué archivo de contexto debería actualizarse
   - El prompt/texto propuesto como cambio
   - La evidencia de cómo se descubrió
4. **Se crea una PR** en `thestark77/be-code-kit`
5. **El equipo revisa y vota** — si tiene sentido, se mergea
6. **El conocimiento se integra** — toda IA de todo el equipo se beneficia

> **Cada descubrimiento que compartís hace que la IA sea más inteligente para TODO el equipo.** Es como entrenar un cerebro colectivo.

### Ejemplos de descubrimientos valiosos

| Descubrimiento | Archivo destino |
|---------------|----------------|
| "El campo `balanceMarketing` está deprecated — 0 negocios lo usan" | `business_logic.md` |
| "Sirse devuelve timeout si el request tarda más de 15s" | `guidelines.md` |
| "La tabla TRI tiene registros huérfanos de Venezuela que son pilotos" | `business_logic.md` |
| "El middleware de face detection solo aplica a montos > 500K COP" | `guidelines.md` |
| "El cron de limpieza de sesiones corre cada 6 horas pero debería ser cada 1" | `Bemovil2questions.md` |

### Templates y carpeta de proposals

- `feedback/FEEDBACK_TEMPLATE.md` — Plantilla para problemas con herramientas
- `feedback/DISCOVERY_TEMPLATE.md` — Plantilla para descubrimientos
- `proposals/` — Carpeta donde quedan los archivos mergeados como registro permanente

> No necesitás saber cómo arreglarlo técnicamente — describí lo que encontraste y el equipo decide juntos cómo integrarlo.

---

## 💻 Cómo usar Claude Code con este setup

### Flujo diario de trabajo

```bash
# 1. Abrí la terminal en la carpeta del proyecto
cd Bemovil2.0

# 2. Arrancá Claude Code
claude

# 3. autoSDD se activa automáticamente
#    La IA ya conoce el contexto del proyecto, las convenciones,
#    la lógica de negocio, y tiene acceso a los skills.

# 4. Pedí lo que necesités
#    Ejemplo: "Creá un endpoint para consultar el saldo de un negocio"
#    autoSDD va a: crear versión → planificar → delegar a backend-dev → ejecutar
```

### Tips de uso

| Situación | Qué hacer |
|-----------|-----------|
| Tarea compleja (nuevo feature) | Dejá que autoSDD orqueste — describí el resultado esperado |
| Pregunta rápida | Prefijá con `[raw]` para saltear autoSDD |
| Crear tests E2E | Escribí `/e2e-forge` y seguí las instrucciones |
| Revisar código | Usá el plugin `code-review` sobre un PR |
| Buscar un skill | Preguntá "¿qué skills tengo disponibles?" |
| Memoria entre sesiones | Engram guarda automáticamente — preguntá "¿qué recordás de la sesión anterior?" |
| Browser testing | Siempre con `--headed` para ver el navegador |

### Comandos especiales dentro de Claude Code

| Comando | Efecto |
|---------|--------|
| `/e2e-forge` | Activa E2E Forge para crear/actualizar tests |
| `[raw]` (prefijo) | Desactiva autoSDD para esa pregunta |
| `[no-sdd]` (prefijo) | Igual que `[raw]` |
| `skip autosdd` (prefijo) | Igual que `[raw]` |
| `FEEDBACK DE USO` | Reporta problemas/mejoras sobre las herramientas de IA |
| `DESCUBRIMIENTO` | Documenta algo importante que descubriste sobre el proyecto |

---

## 📋 Comandos útiles de referencia

```bash
# ═══════════════════════════════════════
# Claude Code
# ═══════════════════════════════════════
claude                                   # Iniciar sesión

# ═══════════════════════════════════════
# Backend (Express 5 + TypeScript)
# ═══════════════════════════════════════
cd backend && pnpm dev                   # Servidor de desarrollo
cd backend && pnpm test                  # Tests E2E (requiere SSH tunnel a DB)
cd backend && pnpm run eslint            # Lint + format

# ═══════════════════════════════════════
# Frontend (Vue 3 + Vite)
# ═══════════════════════════════════════
cd frontend && pnpm dev                  # Servidor de desarrollo
cd frontend && pnpm run eslint           # Lint

# ═══════════════════════════════════════
# Admin (Vue 3 — BeOne CRM/ERP)
# ═══════════════════════════════════════
cd admin && pnpm dev                     # Servidor de desarrollo

# ═══════════════════════════════════════
# Proxy (Green-Blue Deploys)
# ═══════════════════════════════════════
cd bemovil2-proxy && pnpm dev            # Servidor de desarrollo

# ═══════════════════════════════════════
# Utilidades
# ═══════════════════════════════════════
npx playwright install chromium          # Instalar Playwright
npx playwright test --headed             # Correr tests de browser
```

---

## 🔥 Troubleshooting

<details>
<summary><strong>"No tengo acceso al repo"</strong></summary>

**Causa**: Tu cuenta de GitHub no está en la organización IT-Bemovil.

**Solución**: Pedile al Tech Lead que te agregue a la org [IT-Bemovil](https://github.com/IT-Bemovil) en GitHub. Necesitás acceso de lectura como mínimo.

```bash
# Después de que te agreguen, clonalo manualmente:
cd Bemovil2.0
git clone https://github.com/IT-Bemovil/bemovil2.0-backend.git backend
```
</details>

<details>
<summary><strong>"autoSDD no se activa"</strong></summary>

**Causa**: La skill de autoSDD no se instaló correctamente.

**Solución**:
1. Verificá que existe `~/.claude/skills/autosdd/SKILL.md`
2. Si no existe, reinstalá:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh)
   ```
3. Reiniciá Claude Code
</details>

<details>
<summary><strong>".env validation error" al arrancar el backend</strong></summary>

**Causa**: Faltan variables de entorno requeridas.

**Solución**:
1. Revisá `backend/config/env.config.ts` para ver qué variables son obligatorias
2. Compará con tu `.env` — probablemente te faltan algunas
3. Pedile al Tech Lead las variables de sandbox
</details>

<details>
<summary><strong>"E2E Forge no funciona" / "Axiom query failed"</strong></summary>

**Causa**: Falta el `AXIOM_QUERY_TOKEN` en `backend/.env`.

**Solución**: Pedile al Tech Lead el token de Axiom y agregalo a `backend/.env`:
```bash
AXIOM_QUERY_TOKEN=xapt-xxxxxxxx
```
</details>

<details>
<summary><strong>"Playwright error: browser not found"</strong></summary>

**Causa**: Los browsers de Playwright no están instalados.

**Solución**:
```bash
npx playwright install chromium
```
</details>

<details>
<summary><strong>"Claude Code pide autenticación"</strong></summary>

**Causa**: Primera ejecución o token expirado.

**Solución**: Seguí las instrucciones en pantalla para autenticarte con tu cuenta de Anthropic (la que tiene el plan Pro que paga la empresa).
</details>

<details>
<summary><strong>"El instalador falla en Windows"</strong></summary>

**Causa**: Estás usando CMD en vez de PowerShell o Git Bash.

**Solución**: Usá una de estas opciones:
- **PowerShell**: `.\install.ps1`
- **Git Bash**: `bash install.sh`
- **WSL**: `bash install.sh`
</details>

---

## 🔗 Proyectos relacionados

| Proyecto | Repo | Descripción |
|----------|------|-------------|
| **autoSDD** | [github.com/thestark77/autosdd](https://github.com/thestark77/autosdd) | Framework de desarrollo autónomo para agentes de IA |
| **E2E Forge** | [github.com/thestark77/e2e-forge](https://github.com/thestark77/e2e-forge) | Tests E2E automatizados con Axiom |
| **stark-kit** | [github.com/thestark77/stark-kit](https://github.com/thestark77/stark-kit) | Versión genérica del kit (sin contexto Bemovil) |

---

## 🤝 Contributing / Feedback

Este kit es de todo el equipo. Hay varias formas de contribuir:

1. **Sistema de feedback** — Escribí "FEEDBACK DE USO" en tu sesión de Claude Code
2. **PRs directos** — Si sabés exactamente qué cambiar, mandá un PR al repo
3. **Issues** — Reportá bugs o sugerencias en [github.com/thestark77/be-code-kit/issues](https://github.com/thestark77/be-code-kit/issues)
4. **Conversación** — Hablalo con el equipo, las mejores ideas salen de la discusión

> Si algo no funciona, si algo te parece raro, si encontrás una mejor forma de hacer algo — **decilo**. Este kit mejora con el input de todos.

---

## 📄 Licencia

MIT

---

<p align="center">
  <sub>Hecho con cuidado para el equipo Bemovil por <a href="https://github.com/thestark77">@thestark77</a></sub>
</p>
