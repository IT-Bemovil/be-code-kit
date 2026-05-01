#Requires -Version 5.1

# be-code-kit — Bemovil 2.0 Development Environment Installer (PowerShell)
# Usage:
#   git clone https://github.com/IT-Bemovil/be-code-kit.git; cd be-code-kit; .\install.ps1 [TARGET_DIR]
#
# TARGET_DIR defaults to current script directory's parent + "Bemovil2.0"

param(
  [string]$TargetDir
)

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (-not $TargetDir) {
  $TargetDir = Join-Path (Split-Path -Parent $ScriptDir) "Bemovil2.0"
}

# ── Helpers ──────────────────────────────────────────

function Print-Header {
  Write-Host ""
  Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
  Write-Host "  ║  " -ForegroundColor Cyan -NoNewline
  Write-Host "be-code-kit" -NoNewline -ForegroundColor White
  Write-Host " — Bemovil 2.0 Dev Environment Setup     " -NoNewline
  Write-Host "║" -ForegroundColor Cyan
  Write-Host "  ║  Replicates the team's exact Claude Code setup        ║" -ForegroundColor Cyan
  Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
  Write-Host ""
}

function Print-Step {
  param([int]$Num, [string]$Msg)
  Write-Host ""
  Write-Host "[$Num/$TotalSteps] " -ForegroundColor Blue -NoNewline
  Write-Host $Msg -ForegroundColor White
}

function Print-Ok {
  param([string]$Msg)
  Write-Host "  ✓ " -ForegroundColor Green -NoNewline
  Write-Host $Msg
}

function Print-Warn {
  param([string]$Msg)
  Write-Host "  ⚠ " -ForegroundColor Yellow -NoNewline
  Write-Host $Msg
}

function Print-Error {
  param([string]$Msg)
  Write-Host "  ✗ " -ForegroundColor Red -NoNewline
  Write-Host $Msg
}

function Print-Info {
  param([string]$Msg)
  Write-Host "  → " -ForegroundColor Cyan -NoNewline
  Write-Host $Msg
}

$TotalSteps = 8
$Warnings = [System.Collections.Generic.List[string]]::new()
$ClonedRepos = [System.Collections.Generic.List[string]]::new()
$FailedRepos = [System.Collections.Generic.List[string]]::new()

Print-Header

# ═══════════════════════════════════════════
# STEP 0: Prerequisites check
# ═══════════════════════════════════════════
Print-Step 0 "Verificando requisitos..."

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Print-Error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  exit 1
}
Print-Ok "git instalado"

# Check claude CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Print-Error "Claude Code CLI no encontrado."
  Write-Host ""
  Write-Host "  Instala Claude Code primero:"
  Write-Host "    npm install -g @anthropic-ai/claude-code"
  Write-Host "    o visita: https://claude.ai/code"
  Write-Host ""
  exit 1
}
Print-Ok "Claude Code CLI instalado"

# Check npm/pnpm
$PkgMgr = $null
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
  $PkgMgr = "pnpm"
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
  $PkgMgr = "npm"
} else {
  Print-Error "npm o pnpm requerido. Instala Node.js: https://nodejs.org"
  exit 1
}
Print-Ok "$PkgMgr disponible"

# ═══════════════════════════════════════════
# STEP 1: Directory validation
# ═══════════════════════════════════════════
Print-Step 1 "Preparando directorio de destino: $TargetDir"

$UpdateMode = $false

if (Test-Path $TargetDir) {
  $existingItems = Get-ChildItem -Path $TargetDir -Force |
    Where-Object { $_.Name -ne '.git' }

  if ($existingItems.Count -gt 0) {
    Write-Host ""
    Print-Warn "El directorio ya contiene archivos."
    Print-Warn "Se actualizarán los archivos de configuración (CLAUDE.md, context/, .claude/)."
    Print-Warn "NO se tocarán las carpetas de repositorios existentes (backend/, frontend/, admin/, bemovil2-proxy/)."
    Write-Host ""

    $confirm = Read-Host "  ¿Continuar con la actualización? [y/N]"
    if ($confirm -notmatch '^[Yy]$') {
      Write-Host "  Instalación cancelada."
      exit 0
    }

    $UpdateMode = $true
  }
}

if (-not (Test-Path $TargetDir)) {
  New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}
Print-Ok "Directorio listo: $TargetDir"

# ═══════════════════════════════════════════
# STEP 2: Copy template files
# ═══════════════════════════════════════════
Print-Step 2 "Copiando archivos de configuración..."

# Create directory structure
$contextVersionsDir = Join-Path $TargetDir "context/appVersions"
$claudeDir = Join-Path $TargetDir ".claude"
New-Item -ItemType Directory -Path $contextVersionsDir -Force | Out-Null
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

# Copy CLAUDE.md, AGENTS.md, .gitignore, PROGRESS.md
foreach ($f in @("CLAUDE.md", "AGENTS.md", ".gitignore", "PROGRESS.md")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f copiado"
  }
}

# Copy .claude/settings.json (project hooks)
$settingsSrc = Join-Path $ScriptDir "templates/.claude/settings.json"
if (Test-Path $settingsSrc) {
  Copy-Item -Path $settingsSrc -Destination (Join-Path $claudeDir "settings.json") -Force
  Print-Ok ".claude/settings.json (hooks) configurado"
}

# Copy opencode.json and opencode.md (OpenCode CLI config)
foreach ($f in @("opencode.json", "opencode.md")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f copiado (OpenCode compatible)"
  }
}

# ── Detect available AI agents ──────────────────────────────────
Write-Host ""
Print-Step "" "Detectando agente de IA..."
$HasClaude = $false
$HasOpenCode = $false

if (Get-Command claude -ErrorAction SilentlyContinue) {
  $HasClaude = $true
  Print-Ok "Claude Code CLI detectado"
} else {
  Print-Info "Claude Code CLI no encontrado"
}

if (Get-Command opencode -ErrorAction SilentlyContinue) {
  $HasOpenCode = $true
  Print-Ok "OpenCode CLI detectado"
} else {
  Print-Info "OpenCode CLI no encontrado (instalar desde opencode.ai)"
}

if ($HasClaude -and $HasOpenCode) {
  Print-Ok "Ambos agentes detectados — configuraciones instaladas para ambos (sin conflictos)"
} elseif ($HasClaude) {
  Print-Ok "Usando Claude Code CLI — hooks en .claude/settings.json activos"
} elseif ($HasOpenCode) {
  Print-Ok "Usando OpenCode — instrucciones en opencode.md activas (no necesita hooks)"
} else {
  Print-Warn "Ningún agente de IA detectado. Instalá Claude Code CLI u OpenCode."
  Print-Info "  Claude Code: npm install -g @anthropic-ai/claude-code"
  Print-Info "  OpenCode:    ver https://opencode.ai"
}

# Copy context files
$contextDir = Join-Path $TargetDir "context"
foreach ($f in @("guidelines.md", "business_logic.md", "user_context.md", "Bemovil2questions.md", "blokayExample.md")) {
  $src = Join-Path $ScriptDir "templates/context/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $contextDir $f) -Force
    Print-Ok "context/$f copiado"
  }
}

# ═══════════════════════════════════════════
# STEP 3: Create .env template files
# ═══════════════════════════════════════════
Print-Step 3 "Creando plantillas de variables de entorno..."

$RepoDirs = @{
  backend  = "backend"
  frontend = "frontend"
  admin    = "admin"
  proxy    = "bemovil2-proxy"
}

$EnvFiles = @{
  backend  = "backend.env"
  frontend = "frontend.env"
  admin    = "admin.env"
  proxy    = "proxy.env"
}

foreach ($key in $RepoDirs.Keys) {
  $dir = $RepoDirs[$key]
  $envFile = $EnvFiles[$key]
  $subDir = Join-Path $TargetDir $dir
  $targetEnv = Join-Path $subDir ".env"
  $envSrc = Join-Path $ScriptDir "env-templates/$envFile"

  if ((Test-Path $subDir) -and -not (Test-Path $targetEnv)) {
    if (Test-Path $envSrc) {
      Copy-Item -Path $envSrc -Destination $targetEnv -Force
      Print-Ok ".env creado en $dir/ (plantilla vacía)"
    }
  } elseif (-not (Test-Path $subDir)) {
    Print-Info ".env de $dir se creará después del clonado"
  } else {
    Print-Info ".env de $dir ya existe, no se sobreescribe"
  }
}

# ═══════════════════════════════════════════
# STEP 4: Clone repositories
# ═══════════════════════════════════════════
Print-Step 4 "Clonando repositorios de Bemovil 2.0..."

$Repos = [ordered]@{
  backend          = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-backend.git";        Branch = "master" }
  frontend         = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-frontend.git";       Branch = "main" }
  admin            = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-frontend-admin.git";  Branch = "main" }
  "bemovil2-proxy" = @{ Url = "https://github.com/IT-Bemovil/bemovil2-proxy.git";            Branch = "main" }
}

foreach ($dir in $Repos.Keys) {
  $repoUrl = $Repos[$dir].Url
  $defaultBranch = $Repos[$dir].Branch
  $targetPath = Join-Path $TargetDir $dir

  if (Test-Path (Join-Path $targetPath ".git")) {
    Print-Info "$dir/ ya existe, saltando clonado"
    $ClonedRepos.Add("$dir (existente)")
    continue
  }

  Print-Info "Clonando $dir desde $repoUrl ($defaultBranch)..."

  $cloneResult = git clone --branch $defaultBranch $repoUrl $targetPath 2>&1
  if ($LASTEXITCODE -eq 0) {
    Print-Ok "$dir clonado exitosamente"
    $ClonedRepos.Add($dir)

    # Create .env from template if it doesn't exist
    $envKey = $dir
    if ($dir -eq "bemovil2-proxy") { $envKey = "proxy" }
    $envFile = $EnvFiles[$envKey]
    $envSrc = Join-Path $ScriptDir "env-templates/$envFile"
    $envDest = Join-Path $targetPath ".env"
    if ($envFile -and (Test-Path $envSrc) -and -not (Test-Path $envDest)) {
      Copy-Item -Path $envSrc -Destination $envDest -Force
      Print-Ok ".env plantilla creada en $dir/"
    }
  } else {
    Print-Warn "$dir`: no se pudo clonar (¿sin acceso al repo?)"
    $FailedRepos.Add($dir)
    $Warnings.Add("No se pudo clonar $dir. Verifica tu acceso a $repoUrl")
  }
}

# ═══════════════════════════════════════════
# STEP 5: Install autoSDD
# ═══════════════════════════════════════════
Print-Step 5 "Instalando autoSDD..."
Print-Info "Esto abrirá el instalador interactivo de autoSDD."
Print-Info "Selecciona los agentes que uses (al menos claude-code)."
Write-Host ""

try {
  Invoke-RestMethod https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | Invoke-Expression
  Print-Ok "autoSDD instalado exitosamente"
} catch {
  # Fallback: try bash installer via Git Bash if available
  $gitBash = Get-Command bash -ErrorAction SilentlyContinue
  if ($gitBash) {
    Print-Info "Intentando instalador bash como fallback..."
    bash -c 'curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash'
    if ($LASTEXITCODE -eq 0) {
      Print-Ok "autoSDD instalado via bash"
    } else {
      Print-Warn "autoSDD pudo haber tenido errores. Verifica la instalación."
      $Warnings.Add("Verifica que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
    }
  } else {
    Print-Warn "autoSDD pudo haber tenido errores. Verifica la instalación."
    $Warnings.Add("Verifica que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
  }
}

# ═══════════════════════════════════════════
# STEP 6: Install E2E Forge
# ═══════════════════════════════════════════
Print-Step 6 "Instalando E2E Forge..."

$e2eTmp = Join-Path $env:TEMP "e2e-forge-install"
if (Test-Path $e2eTmp) {
  Remove-Item -Recurse -Force $e2eTmp
}

$cloneResult = git clone --depth 1 https://github.com/thestark77/e2e-forge.git $e2eTmp 2>&1
if ($LASTEXITCODE -eq 0) {
  $installerPs1 = Join-Path $e2eTmp "install.ps1"
  $installerSh = Join-Path $e2eTmp "install.sh"

  if (Test-Path $installerPs1) {
    & $installerPs1
    Print-Ok "E2E Forge instalado"
  } elseif (Test-Path $installerSh) {
    $gitBash = Get-Command bash -ErrorAction SilentlyContinue
    if ($gitBash) {
      bash $installerSh
      Print-Ok "E2E Forge instalado via bash"
    } else {
      # Manual copy fallback
      $skillDir = Join-Path $env:USERPROFILE ".claude/skills/e2e-forge"
      New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
      Copy-Item -Path (Join-Path $e2eTmp "*") -Destination $skillDir -Recurse -Force
      Print-Ok "E2E Forge copiado manualmente"
    }
  } else {
    # Manual copy fallback
    $skillDir = Join-Path $env:USERPROFILE ".claude/skills/e2e-forge"
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Copy-Item -Path (Join-Path $e2eTmp "*") -Destination $skillDir -Recurse -Force
    Print-Ok "E2E Forge copiado manualmente"
  }
  Remove-Item -Recurse -Force $e2eTmp -ErrorAction SilentlyContinue
} else {
  Print-Warn "No se pudo clonar E2E Forge. Instálalo manualmente:"
  Print-Info "git clone https://github.com/thestark77/e2e-forge.git; cd e2e-forge; .\install.ps1"
  $Warnings.Add("E2E Forge no se instaló. Instálalo manualmente.")
}

# ═══════════════════════════════════════════
# STEP 7: Install additional skills & plugins
# ═══════════════════════════════════════════
Print-Step 7 "Instalando skills y plugins adicionales..."

# Skills that autoSDD might NOT install (extras for Bemovil workflow)
$ExtraSkills = @(
  "JuliusBrussee/caveman"
  "vercel-labs/agent-skills"
  "shadcn-ui/ui"
  "gentleman-programming/sdd-agent-team"
  "davidcastagnetoa/skills"
)

foreach ($skillRepo in $ExtraSkills) {
  $skillName = Split-Path -Leaf $skillRepo
  Print-Info "Instalando skill: $skillName..."
  $result = claude skill install "github:$skillRepo" 2>&1
  if ($LASTEXITCODE -eq 0) {
    Print-Ok "$skillName instalado"
  } else {
    Print-Info "$skillName ya instalado o no disponible"
  }
}

# Plugins
Write-Host ""
Print-Info "Instalando plugins de Claude Code..."

$Plugins = @(
  @{ Name = "claude-powerline"; Id = "claude-powerline@claude-powerline" }
  @{ Name = "engram";           Id = "engram@engram" }
  @{ Name = "frontend-design";  Id = "frontend-design@claude-plugins-official" }
  @{ Name = "code-review";      Id = "code-review@claude-plugins-official" }
  @{ Name = "code-simplifier";  Id = "code-simplifier@claude-plugins-official" }
)

foreach ($plugin in $Plugins) {
  Print-Info "Plugin: $($plugin.Name)..."
  $result = claude plugin install $plugin.Id 2>&1
  if ($LASTEXITCODE -eq 0) {
    Print-Ok "$($plugin.Name) instalado"
  } else {
    Print-Info "$($plugin.Name) ya instalado o no disponible"
  }
}

# MCP Servers
Write-Host ""
Print-Info "Configurando MCP servers..."

Print-Info "MCP: linear-server..."
$result = claude mcp add linear-server --transport sse --url "https://mcp.linear.app/sse" 2>&1
if ($LASTEXITCODE -eq 0) {
  Print-Ok "linear-server MCP configurado (requiere autenticación)"
} else {
  Print-Info "linear-server ya configurado o no disponible"
}

# ═══════════════════════════════════════════
# STEP 8: Initialize git repo at root
# ═══════════════════════════════════════════
Print-Step 8 "Finalizando configuración..."

Push-Location $TargetDir

# Init root git repo if not exists
if (-not (Test-Path ".git")) {
  git init -q
  git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json opencode.json opencode.md 2>$null
  git commit -q -m "init: be-code-kit setup"
  Print-Ok "Repositorio raíz inicializado"
} else {
  Print-Info "Repositorio raíz ya existe"
}

# Create appVersions/v0.1.0
$v010Dir = Join-Path $TargetDir "context/appVersions/v0.1.0"
New-Item -ItemType Directory -Path $v010Dir -Force | Out-Null

Pop-Location

# ═══════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════
Write-Host ""
Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "    ¡Instalación completada!" -ForegroundColor Green
Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Directorio: " -NoNewline -ForegroundColor White
Write-Host $TargetDir
Write-Host ""

if ($ClonedRepos.Count -gt 0) {
  Write-Host "  Repositorios clonados:" -ForegroundColor Green
  foreach ($r in $ClonedRepos) {
    Write-Host "    ✓ " -ForegroundColor Green -NoNewline
    Write-Host $r
  }
}

if ($FailedRepos.Count -gt 0) {
  Write-Host ""
  Write-Host "  Repositorios sin acceso:" -ForegroundColor Yellow
  foreach ($r in $FailedRepos) {
    Write-Host "    ⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $r
  }
}

if ($Warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "  Advertencias:" -ForegroundColor Yellow
  foreach ($w in $Warnings) {
    Write-Host "    ⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $w
  }
}

Write-Host ""
Write-Host "  Próximos pasos:" -ForegroundColor White
Write-Host "    1. Pega tus variables de entorno (.env) en cada sub-proyecto"
Write-Host "       → Pide las credenciales de sandbox a tu equipo"
Write-Host "    2. Instala dependencias en cada proyecto: cd backend && $PkgMgr install"
Write-Host "    3. Abrí tu agente de IA:"
Write-Host "       Claude Code: cd $TargetDir && claude"
Write-Host "       OpenCode:    cd $TargetDir && opencode"
Write-Host "    4. Configura Axiom: pega el AXIOM_QUERY_TOKEN en backend/.env"
Write-Host ""
Write-Host "  Lee el README.md para el tutorial completo." -ForegroundColor White
Write-Host ""
