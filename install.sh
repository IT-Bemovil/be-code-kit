#!/usr/bin/env bash
set -uo pipefail

# be-code-kit — Bemovil 2.0 Development Environment Installer
# Usage:
#   git clone https://github.com/IT-Bemovil/be-code-kit.git && cd be-code-kit && bash install.sh [TARGET_DIR]
#
# TARGET_DIR defaults to current working directory's parent + "Bemovil2.0"

_becode_install() {

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(dirname "$SCRIPT_DIR")/Bemovil2.0}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}be-code-kit${NC} — Bemovil 2.0 Dev Environment Setup     ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  Replicates the team's exact Claude Code setup        ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() { echo -e "\n${BLUE}[$1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"; }
print_ok() { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "  ${RED}✗${NC} $1"; }
print_info() { echo -e "  ${CYAN}→${NC} $1"; }

TOTAL_STEPS=8
WARNINGS=()
CLONED_REPOS=()
FAILED_REPOS=()

print_header

# ═══════════════════════════════════════════
# STEP 0: Prerequisites check
# ═══════════════════════════════════════════
print_step 0 "Verificando requisitos..."

# Check git
if ! command -v git &>/dev/null; then
  print_error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  return 1
fi
print_ok "git instalado"

# Check claude CLI
if ! command -v claude &>/dev/null; then
  print_error "Claude Code CLI no encontrado."
  echo ""
  echo "  Instala Claude Code primero:"
  echo "    npm install -g @anthropic-ai/claude-code"
  echo "    o visita: https://claude.ai/code"
  echo ""
  return 1
fi
print_ok "Claude Code CLI instalado"

# Check npm/pnpm
if command -v pnpm &>/dev/null; then
  PKG_MGR="pnpm"
elif command -v npm &>/dev/null; then
  PKG_MGR="npm"
else
  print_error "npm o pnpm requerido. Instala Node.js: https://nodejs.org"
  return 1
fi
print_ok "$PKG_MGR disponible"

# ═══════════════════════════════════════════
# STEP 1: Directory validation
# ═══════════════════════════════════════════
print_step 1 "Preparando directorio de destino: ${TARGET_DIR}"

UPDATE_MODE=false

if [ -d "$TARGET_DIR" ]; then
  # Check if it already has content
  file_count=$(find "$TARGET_DIR" -maxdepth 1 -not -name '.' -not -name '..' -not -name '.git' | wc -l)

  if [ "$file_count" -gt 0 ]; then
    echo ""
    print_warn "El directorio ya contiene archivos."
    print_warn "Se actualizarán los archivos de configuración (CLAUDE.md, context/, .claude/)."
    print_warn "NO se tocarán las carpetas de repositorios existentes (backend/, frontend/, admin/, bemovil2-proxy/)."
    echo ""

    if [[ -r /dev/tty ]]; then
      read -rp "  ¿Continuar con la actualización? [y/N]: " confirm </dev/tty || confirm=""
    else
      confirm="y"
    fi

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "  Instalación cancelada."
      return 0
    fi

    UPDATE_MODE=true
  fi
fi

mkdir -p "$TARGET_DIR"
print_ok "Directorio listo: $TARGET_DIR"

# ═══════════════════════════════════════════
# STEP 2: Copy template files
# ═══════════════════════════════════════════
print_step 2 "Copiando archivos de configuración..."

# Create directory structure
mkdir -p "$TARGET_DIR/context/appVersions"
mkdir -p "$TARGET_DIR/.claude"

# Copy CLAUDE.md, AGENTS.md, .gitignore, PROGRESS.md
for f in CLAUDE.md AGENTS.md .gitignore PROGRESS.md; do
  if [ -f "$SCRIPT_DIR/templates/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$TARGET_DIR/$f"
    print_ok "$f copiado"
  fi
done

# Copy .claude/settings.json (project hooks)
if [ -f "$SCRIPT_DIR/templates/.claude/settings.json" ]; then
  cp "$SCRIPT_DIR/templates/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
  print_ok ".claude/settings.json (hooks) configurado"
fi

# Copy context files
for f in guidelines.md business_logic.md user_context.md Bemovil2questions.md blokayExample.md; do
  if [ -f "$SCRIPT_DIR/templates/context/$f" ]; then
    cp "$SCRIPT_DIR/templates/context/$f" "$TARGET_DIR/context/$f"
    print_ok "context/$f copiado"
  fi
done

# ═══════════════════════════════════════════
# STEP 3: Create .env template files
# ═══════════════════════════════════════════
print_step 3 "Creando plantillas de variables de entorno..."

declare -A REPO_DIRS=(
  ["backend"]="backend"
  ["frontend"]="frontend"
  ["admin"]="admin"
  ["proxy"]="bemovil2-proxy"
)

declare -A ENV_FILES=(
  ["backend"]="backend.env"
  ["frontend"]="frontend.env"
  ["admin"]="admin.env"
  ["proxy"]="proxy.env"
)

for key in "${!REPO_DIRS[@]}"; do
  dir="${REPO_DIRS[$key]}"
  env_file="${ENV_FILES[$key]}"
  target_env="$TARGET_DIR/$dir/.env"

  # Only create .env if the directory exists and .env doesn't
  if [ -d "$TARGET_DIR/$dir" ] && [ ! -f "$target_env" ]; then
    if [ -f "$SCRIPT_DIR/env-templates/$env_file" ]; then
      cp "$SCRIPT_DIR/env-templates/$env_file" "$target_env"
      print_ok ".env creado en $dir/ (plantilla vacía)"
    fi
  elif [ ! -d "$TARGET_DIR/$dir" ]; then
    # Directory doesn't exist yet, will be created when repos are cloned
    print_info ".env de $dir se creará después del clonado"
  else
    print_info ".env de $dir ya existe, no se sobreescribe"
  fi
done

# ═══════════════════════════════════════════
# STEP 4: Clone repositories
# ═══════════════════════════════════════════
print_step 4 "Clonando repositorios de Bemovil 2.0..."

declare -A REPOS=(
  ["backend"]="https://github.com/IT-Bemovil/bemovil2.0-backend.git|master"
  ["frontend"]="https://github.com/IT-Bemovil/bemovil2.0-frontend.git|main"
  ["admin"]="https://github.com/IT-Bemovil/bemovil2.0-frontend-admin.git|main"
  ["bemovil2-proxy"]="https://github.com/IT-Bemovil/bemovil2-proxy.git|main"
)

for dir in backend frontend admin bemovil2-proxy; do
  IFS='|' read -r repo_url default_branch <<< "${REPOS[$dir]}"
  target_path="$TARGET_DIR/$dir"

  if [ -d "$target_path/.git" ]; then
    print_info "$dir/ ya existe, saltando clonado"
    CLONED_REPOS+=("$dir (existente)")
    continue
  fi

  echo -e "  ${CYAN}→${NC} Clonando $dir desde $repo_url ($default_branch)..."

  if git clone --branch "$default_branch" "$repo_url" "$target_path" 2>/dev/null; then
    print_ok "$dir clonado exitosamente"
    CLONED_REPOS+=("$dir")

    # Create .env from template if it doesn't exist
    env_key="$dir"
    [[ "$dir" == "bemovil2-proxy" ]] && env_key="proxy"
    env_file="${ENV_FILES[$env_key]:-}"
    if [ -n "$env_file" ] && [ -f "$SCRIPT_DIR/env-templates/$env_file" ] && [ ! -f "$target_path/.env" ]; then
      cp "$SCRIPT_DIR/env-templates/$env_file" "$target_path/.env"
      print_ok ".env plantilla creada en $dir/"
    fi
  else
    print_warn "$dir: no se pudo clonar (¿sin acceso al repo?)"
    FAILED_REPOS+=("$dir")
    WARNINGS+=("No se pudo clonar $dir. Verifica tu acceso a $repo_url")
  fi
done

# ═══════════════════════════════════════════
# STEP 5: Install autoSDD
# ═══════════════════════════════════════════
print_step 5 "Instalando autoSDD..."
print_info "Esto abrirá el instalador interactivo de autoSDD."
print_info "Selecciona los agentes que uses (al menos claude-code)."
echo ""

if [[ -r /dev/tty ]]; then
  # Run the autoSDD installer interactively
  bash <(curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh) </dev/tty
  autosdd_status=$?
else
  curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
  autosdd_status=$?
fi

if [ $autosdd_status -eq 0 ]; then
  print_ok "autoSDD instalado exitosamente"
else
  print_warn "autoSDD pudo haber tenido errores. Verifica la instalación."
  WARNINGS+=("Verifica que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
fi

# ═══════════════════════════════════════════
# STEP 6: Install E2E Forge
# ═══════════════════════════════════════════
print_step 6 "Instalando E2E Forge..."

E2E_TMP="/tmp/e2e-forge-install"
rm -rf "$E2E_TMP"

if git clone --depth 1 https://github.com/thestark77/e2e-forge.git "$E2E_TMP" 2>/dev/null; then
  if [ -f "$E2E_TMP/install.sh" ]; then
    bash "$E2E_TMP/install.sh"
    print_ok "E2E Forge instalado"
  else
    # Manual copy fallback
    mkdir -p "$HOME/.claude/skills/e2e-forge"
    cp -r "$E2E_TMP/"* "$HOME/.claude/skills/e2e-forge/" 2>/dev/null
    print_ok "E2E Forge copiado manualmente"
  fi
  rm -rf "$E2E_TMP"
else
  print_warn "No se pudo clonar E2E Forge. Instálalo manualmente:"
  print_info "git clone https://github.com/thestark77/e2e-forge.git /tmp/e2e-forge && bash /tmp/e2e-forge/install.sh"
  WARNINGS+=("E2E Forge no se instaló. Instálalo manualmente.")
fi

# ═══════════════════════════════════════════
# STEP 7: Install additional skills & plugins
# ═══════════════════════════════════════════
print_step 7 "Instalando skills y plugins adicionales..."

# Skills that autoSDD might NOT install (extras for Bemovil workflow)
EXTRA_SKILLS=(
  "JuliusBrussee/caveman"
  "vercel-labs/agent-skills"
  "shadcn-ui/ui"
  "gentleman-programming/sdd-agent-team"
  "davidcastagnetoa/skills"
)

for skill_repo in "${EXTRA_SKILLS[@]}"; do
  skill_name=$(basename "$skill_repo")
  echo -e "  ${CYAN}→${NC} Instalando skill: $skill_name..."
  if claude skill install "github:$skill_repo" 2>/dev/null; then
    print_ok "$skill_name instalado"
  else
    print_info "$skill_name ya instalado o no disponible"
  fi
done

# Plugins
echo ""
print_info "Instalando plugins de Claude Code..."

PLUGINS=(
  "claude-powerline@claude-powerline"
  "engram@engram"
  "frontend-design@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
)

for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(echo "$plugin" | cut -d'@' -f1)
  echo -e "  ${CYAN}→${NC} Plugin: $plugin_name..."
  if claude plugin install "$plugin" 2>/dev/null; then
    print_ok "$plugin_name instalado"
  else
    print_info "$plugin_name ya instalado o no disponible"
  fi
done

# MCP Servers
echo ""
print_info "Configurando MCP servers..."

echo -e "  ${CYAN}→${NC} MCP: linear-server..."
if claude mcp add linear-server --transport sse --url "https://mcp.linear.app/sse" 2>/dev/null; then
  print_ok "linear-server MCP configurado (requiere autenticación)"
else
  print_info "linear-server ya configurado o no disponible"
fi

# ═══════════════════════════════════════════
# STEP 8: Initialize git repo at root
# ═══════════════════════════════════════════
print_step 8 "Finalizando configuración..."

cd "$TARGET_DIR" || return 1

# Init root git repo if not exists
if [ ! -d ".git" ]; then
  git init -q
  git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json 2>/dev/null
  git commit -q -m "init: be-code-kit setup"
  print_ok "Repositorio raíz inicializado"
else
  print_info "Repositorio raíz ya existe"
fi

# Create appVersions/v0.1.0
mkdir -p "context/appVersions/v0.1.0"

# ═══════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ¡Instalación completada!${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Directorio:${NC} $TARGET_DIR"
echo ""

if [ ${#CLONED_REPOS[@]} -gt 0 ]; then
  echo -e "  ${GREEN}Repositorios clonados:${NC}"
  for r in "${CLONED_REPOS[@]}"; do
    echo -e "    ${GREEN}✓${NC} $r"
  done
fi

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}Repositorios sin acceso:${NC}"
  for r in "${FAILED_REPOS[@]}"; do
    echo -e "    ${YELLOW}⚠${NC} $r"
  done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}Advertencias:${NC}"
  for w in "${WARNINGS[@]}"; do
    echo -e "    ${YELLOW}⚠${NC} $w"
  done
fi

echo ""
echo -e "  ${BOLD}Próximos pasos:${NC}"
echo -e "    1. Pega tus variables de entorno (.env) en cada sub-proyecto"
echo -e "       → Pide las credenciales de sandbox a tu equipo"
echo -e "    2. Instala dependencias en cada proyecto: cd backend && $PKG_MGR install"
echo -e "    3. Abre Claude Code: cd $TARGET_DIR && claude"
echo -e "    4. Configura Axiom: pega el AXIOM_QUERY_TOKEN en backend/.env"
echo ""
echo -e "  ${BOLD}Lee el README.md para el tutorial completo.${NC}"
echo ""

}

_becode_install "$@"
