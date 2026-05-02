#Requires -Version 5.1

# be-code-kit — Bemovil 2.0 Development Environment Installer (PowerShell)
# Uses stark-kit as foundation (autoSDD + skills + plugins) + Bemovil-specific config
#
# Usage:
#   git clone https://github.com/IT-Bemovil/be-code-kit.git; cd be-code-kit; .\install.ps1 [TARGET_DIR]
#
# TARGET_DIR defaults to current script directory's parent + "Bemovil2.0"

param(
  [string]$TargetDir,
  [switch]$Yes
)

$AutoYes = $Yes.IsPresent
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
  Write-Host "  ║  stark-kit + Bemovil context, in one command          ║" -ForegroundColor Cyan
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

$TotalSteps = 6
$Warnings = [System.Collections.Generic.List[string]]::new()
$ClonedRepos = [System.Collections.Generic.List[string]]::new()
$FailedRepos = [System.Collections.Generic.List[string]]::new()

Print-Header

# ═══════════════════════════════════════════
# STEP 0: Prerequisites check
# ═══════════════════════════════════════════
Print-Step 0 "Verificando requisitos..."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Print-Error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  exit 1
}
Print-Ok "git instalado"

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
# STEP 1: Directory validation + legacy cleanup
# ═══════════════════════════════════════════
Print-Step 1 "Preparando directorio de destino: $TargetDir"

$UpdateMode = $false

if (Test-Path $TargetDir) {
  $existingItems = Get-ChildItem -Path $TargetDir -Force |
    Where-Object { $_.Name -ne '.git' }

  if ($existingItems.Count -gt 0) {
    Write-Host ""
    Print-Warn "El directorio ya contiene archivos."
    Print-Warn "Se actualizará a la nueva versión (stark-kit + Bemovil config)."
    Print-Warn "NO se tocarán repos existentes (backend/, frontend/, admin/, bemovil2-proxy/)."
    Write-Host ""

    if ($AutoYes) {
      $confirm = "y"
    } else {
      $confirm = Read-Host "  ¿Continuar con la actualización? [y/N]"
    }
    if ($confirm -notmatch '^[Yy]$') {
      Write-Host "  Instalación cancelada."
      exit 0
    }

    $UpdateMode = $true

    # Clean up artifacts from old independent installations
    Print-Info "Limpiando artefactos de versiones anteriores..."
    foreach ($d in @("src", "tests")) {
      $dPath = Join-Path $TargetDir $d
      if ((Test-Path $dPath) -and ((Get-ChildItem -Path $dPath -Force -ErrorAction SilentlyContinue).Count -eq 0)) {
        Remove-Item -Recurse -Force $dPath
        Print-Ok "Removido $d/ vacío (artefacto de stark-kit genérico)"
      }
    }
  }
}

if (-not (Test-Path $TargetDir)) {
  New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}
Print-Ok "Directorio listo: $TargetDir"

# ═══════════════════════════════════════════
# STEP 2: Install stark-kit (foundation)
# ═══════════════════════════════════════════
Print-Step 2 "Instalando stark-kit (autoSDD + skills + plugins)..."
Print-Info "stark-kit instala: autoSDD, skills de desarrollo, plugins, Engram MCP."
Print-Info "El instalador de autoSDD te pedirá seleccionar agentes (al menos claude-code)."
Write-Host ""

$starkTmp = Join-Path $env:TEMP "stark-kit-install"
if (Test-Path $starkTmp) { Remove-Item -Recurse -Force $starkTmp }

$cloneResult = git clone --depth 1 https://github.com/thestark77/stark-kit.git $starkTmp 2>&1
if ($LASTEXITCODE -eq 0) {
  $starkInstaller = Join-Path $starkTmp "install.ps1"
  if (Test-Path $starkInstaller) {
    & $starkInstaller -TargetDir $TargetDir -Yes
    Print-Ok "stark-kit instalado exitosamente"
  } else {
    Print-Warn "Instalador de stark-kit no encontrado en el repo clonado."
    $Warnings.Add("Verifica que stark-kit se instaló correctamente")
  }
  Remove-Item -Recurse -Force $starkTmp -ErrorAction SilentlyContinue
} else {
  # Fallback: try bash installer via Git Bash
  $gitBash = Get-Command bash -ErrorAction SilentlyContinue
  if ($gitBash) {
    Print-Info "Intentando instalador bash como fallback..."
    bash -c "curl -fsSL https://raw.githubusercontent.com/thestark77/stark-kit/main/install.sh | bash -s -- `"$TargetDir`" --yes"
    if ($LASTEXITCODE -eq 0) {
      Print-Ok "stark-kit instalado via bash"
    } else {
      Print-Warn "stark-kit pudo haber tenido errores. Verifica la instalación."
      $Warnings.Add("Verifica que stark-kit se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
    }
  } else {
    Print-Warn "No se pudo clonar stark-kit. Verifica tu conexión a internet."
    $Warnings.Add("Verifica que stark-kit se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
  }
}

# Remove stark-kit generic dirs not relevant for Bemovil monorepo
foreach ($d in @("src", "tests")) {
  $dPath = Join-Path $TargetDir $d
  if ((Test-Path $dPath) -and ((Get-ChildItem -Path $dPath -Force -ErrorAction SilentlyContinue).Count -eq 0)) {
    Remove-Item -Recurse -Force $dPath -ErrorAction SilentlyContinue
  }
}

# ═══════════════════════════════════════════
# STEP 3: Apply Bemovil-specific configuration
# ═══════════════════════════════════════════
Print-Step 3 "Aplicando configuración específica de Bemovil..."

$contextVersionsDir = Join-Path $TargetDir "context/appVersions"
$claudeDir = Join-Path $TargetDir ".claude"
$feedbackDir = Join-Path $TargetDir "feedback"
$proposalsDir = Join-Path $TargetDir "proposals"
New-Item -ItemType Directory -Path $contextVersionsDir -Force | Out-Null
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
New-Item -ItemType Directory -Path $feedbackDir -Force | Out-Null
New-Item -ItemType Directory -Path $proposalsDir -Force | Out-Null

# Override stark-kit generics with Bemovil-specific templates
foreach ($f in @("CLAUDE.md", "AGENTS.md", ".gitignore", "PROGRESS.md")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f (Bemovil) aplicado"
  }
}

# Override .claude/settings.json with Bemovil hooks
$settingsSrc = Join-Path $ScriptDir "templates/.claude/settings.json"
if (Test-Path $settingsSrc) {
  Copy-Item -Path $settingsSrc -Destination (Join-Path $claudeDir "settings.json") -Force
  Print-Ok ".claude/settings.json (Bemovil hooks) aplicado"
}

# Override opencode config with Bemovil-specific versions
foreach ($f in @("opencode.json", "opencode.md")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f (Bemovil) aplicado"
  }
}

# Copy Bemovil context files (overrides + Bemovil-specific)
$contextDir = Join-Path $TargetDir "context"
foreach ($f in @("guidelines.md", "business_logic.md", "user_context.md", "Bemovil2questions.md", "blokayExample.md")) {
  $src = Join-Path $ScriptDir "templates/context/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $contextDir $f) -Force
    Print-Ok "context/$f copiado"
  }
}

# Copy feedback templates
foreach ($f in @("FEEDBACK_TEMPLATE.md", "DISCOVERY_TEMPLATE.md")) {
  $src = Join-Path $ScriptDir "feedback/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $feedbackDir $f) -Force
    Print-Ok "feedback/$f copiado"
  }
}

# ═══════════════════════════════════════════
# STEP 4: Clone repositories + .env templates
# ═══════════════════════════════════════════
Print-Step 4 "Clonando repositorios de Bemovil 2.0..."

$Repos = [ordered]@{
  backend          = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-backend.git";        Branch = "master" }
  frontend         = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-frontend.git";       Branch = "main" }
  admin            = @{ Url = "https://github.com/IT-Bemovil/bemovil2.0-frontend-admin.git";  Branch = "main" }
  "bemovil2-proxy" = @{ Url = "https://github.com/IT-Bemovil/bemovil2-proxy.git";            Branch = "main" }
}

$EnvFiles = @{
  backend          = "backend.env"
  frontend         = "frontend.env"
  admin            = "admin.env"
  "bemovil2-proxy" = "proxy.env"
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
  } else {
    Print-Warn "$dir`: no se pudo clonar (¿sin acceso al repo?)"
    $FailedRepos.Add($dir)
    $Warnings.Add("No se pudo clonar $dir. Verifica tu acceso a $repoUrl")
  }
}

# Create .env templates for all repo dirs
Write-Host ""
Print-Info "Creando plantillas de variables de entorno..."
foreach ($dir in $Repos.Keys) {
  $targetPath = Join-Path $TargetDir $dir
  $envFile = $EnvFiles[$dir]
  $envSrc = Join-Path $ScriptDir "env-templates/$envFile"
  $envDest = Join-Path $targetPath ".env"

  if ((Test-Path $targetPath) -and $envFile -and (Test-Path $envSrc) -and -not (Test-Path $envDest)) {
    Copy-Item -Path $envSrc -Destination $envDest -Force
    Print-Ok ".env plantilla creada en $dir/"
  } elseif ((Test-Path $targetPath) -and (Test-Path $envDest)) {
    Print-Info ".env de $dir ya existe, no se sobreescribe"
  }
}

# ═══════════════════════════════════════════
# STEP 5: Install Bemovil-specific extras
# ═══════════════════════════════════════════
Print-Step 5 "Instalando herramientas específicas de Bemovil..."

# ── E2E Forge ──
Write-Host ""
Print-Info "Instalando E2E Forge..."
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
      $skillDir = Join-Path $env:USERPROFILE ".claude/skills/e2e-forge"
      New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
      Copy-Item -Path (Join-Path $e2eTmp "*") -Destination $skillDir -Recurse -Force
      Print-Ok "E2E Forge copiado manualmente"
    }
  } else {
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

# ── Caveman skill (Bemovil uses it, not in stark-kit) ──
Write-Host ""
Print-Info "Instalando skill: caveman..."
$result = claude skill install "github:JuliusBrussee/caveman" 2>&1
if ($LASTEXITCODE -eq 0) {
  Print-Ok "caveman instalado"
} else {
  Print-Info "caveman ya instalado o no disponible"
}

# ── Linear MCP (task management) ──
Write-Host ""
Print-Info "Configurando MCP: linear-server..."
$result = claude mcp add linear-server --transport sse --url "https://mcp.linear.app/sse" 2>&1
if ($LASTEXITCODE -eq 0) {
  Print-Ok "linear-server MCP configurado (requiere autenticación)"
} else {
  Print-Info "linear-server ya configurado o no disponible"
}

# ═══════════════════════════════════════════
# STEP 6: Finalize
# ═══════════════════════════════════════════
Print-Step 6 "Finalizando configuración..."

Push-Location $TargetDir

if (-not (Test-Path ".git")) {
  git init -q
  git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json feedback/ 2>$null
  git add opencode.json opencode.md 2>$null
  git commit -q -m "init: be-code-kit setup (via stark-kit)"
  Print-Ok "Repositorio raíz inicializado"
} else {
  Print-Info "Repositorio raíz ya existe"
}

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
Write-Host "  Instalado via: " -NoNewline -ForegroundColor White
Write-Host "stark-kit → autoSDD → Bemovil config"
Write-Host ""

if ($ClonedRepos.Count -gt 0) {
  Write-Host "  Repositorios:" -ForegroundColor Green
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
