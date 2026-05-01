#!/usr/bin/env bash
set -uo pipefail

# be-code-kit — Bemovil 2.0 Development Environment Installer
# Uses stark-kit as foundation (autoSDD + skills + plugins) + Bemovil-specific config
#
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
  echo -e "${CYAN}║${NC}  stark-kit + Bemovil context, in one command          ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() { echo -e "\n${BLUE}[$1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_error(){ echo -e "  ${RED}✗${NC} $1"; }
print_info() { echo -e "  ${CYAN}→${NC} $1"; }

TOTAL_STEPS=6
WARNINGS=()
CLONED_REPOS=()
FAILED_REPOS=()

print_header

# ═══════════════════════════════════════════
# STEP 0: Prerequisites check
# ═══════════════════════════════════════════
print_step 0 "Verificando requisitos..."

if ! command -v git &>/dev/null; then
  print_error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  return 1
fi
print_ok "git instalado"

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
# STEP 1: Directory validation + legacy cleanup
# ═══════════════════════════════════════════
print_step 1 "Preparando directorio de destino: ${TARGET_DIR}"

UPDATE_MODE=false

if [ -d "$TARGET_DIR" ]; then
  file_count=$(find "$TARGET_DIR" -maxdepth 1 -not -name '.' -not -name '..' -not -name '.git' | wc -l)

  if [ "$file_count" -gt 0 ]; then
    echo ""
    print_warn "El directorio ya contiene archivos."
    print_warn "Se actualizará a la nueva versión (stark-kit + Bemovil config)."
    print_warn "NO se tocarán repos existentes (backend/, frontend/, admin/, bemovil2-proxy/)."
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

    # Clean up artifacts from old independent be-code-kit installations
    print_info "Limpiando artefactos de versiones anteriores..."
    for d in src tests; do
      if [ -d "$TARGET_DIR/$d" ] && [ -z "$(ls -A "$TARGET_DIR/$d" 2>/dev/null)" ]; then
        rm -rf "$TARGET_DIR/$d"
        print_ok "Removido $d/ vacío (artefacto de stark-kit genérico)"
      fi
    done
  fi
fi

mkdir -p "$TARGET_DIR"
print_ok "Directorio listo: $TARGET_DIR"

# ═══════════════════════════════════════════
# STEP 2: Install stark-kit (foundation)
# ═══════════════════════════════════════════
print_step 2 "Instalando stark-kit (autoSDD + skills + plugins)..."
print_info "stark-kit instala: autoSDD, skills de desarrollo, plugins, Engram MCP."
print_info "El instalador de autoSDD te pedirá seleccionar agentes (al menos claude-code)."
echo ""

if [[ -r /dev/tty ]]; then
  bash <(curl -fsSL https://raw.githubusercontent.com/thestark77/stark-kit/main/install.sh) "$TARGET_DIR" --yes </dev/tty
  starkkit_status=$?
else
  curl -fsSL https://raw.githubusercontent.com/thestark77/stark-kit/main/install.sh | bash -s -- "$TARGET_DIR" --yes
  starkkit_status=$?
fi

if [ $starkkit_status -eq 0 ]; then
  print_ok "stark-kit instalado exitosamente"
else
  print_warn "stark-kit pudo haber tenido errores. Verifica la instalación."
  WARNINGS+=("Verifica que stark-kit se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
fi

# Remove stark-kit generic dirs not relevant for Bemovil monorepo
for d in src tests; do
  if [ -d "$TARGET_DIR/$d" ] && [ -z "$(ls -A "$TARGET_DIR/$d" 2>/dev/null)" ]; then
    rm -rf "$TARGET_DIR/$d"
  fi
done

# ═══════════════════════════════════════════
# STEP 3: Apply Bemovil-specific configuration
# ═══════════════════════════════════════════
print_step 3 "Aplicando configuración específica de Bemovil..."

mkdir -p "$TARGET_DIR/context/appVersions"
mkdir -p "$TARGET_DIR/.claude"
mkdir -p "$TARGET_DIR/feedback"
mkdir -p "$TARGET_DIR/proposals"

# Override stark-kit generics with Bemovil-specific templates
for f in CLAUDE.md AGENTS.md .gitignore PROGRESS.md; do
  if [ -f "$SCRIPT_DIR/templates/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$TARGET_DIR/$f"
    print_ok "$f (Bemovil) aplicado"
  fi
done

# Override .claude/settings.json with Bemovil hooks
if [ -f "$SCRIPT_DIR/templates/.claude/settings.json" ]; then
  cp "$SCRIPT_DIR/templates/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
  print_ok ".claude/settings.json (Bemovil hooks) aplicado"
fi

# Copy Bemovil context files (overrides stark-kit generics + adds Bemovil-specific)
for f in guidelines.md business_logic.md user_context.md Bemovil2questions.md blokayExample.md; do
  if [ -f "$SCRIPT_DIR/templates/context/$f" ]; then
    cp "$SCRIPT_DIR/templates/context/$f" "$TARGET_DIR/context/$f"
    print_ok "context/$f copiado"
  fi
done

# Copy feedback templates
for f in FEEDBACK_TEMPLATE.md DISCOVERY_TEMPLATE.md; do
  if [ -f "$SCRIPT_DIR/feedback/$f" ]; then
    cp "$SCRIPT_DIR/feedback/$f" "$TARGET_DIR/feedback/$f"
    print_ok "feedback/$f copiado"
  fi
done

# ═══════════════════════════════════════════
# STEP 4: Clone repositories + .env templates
# ═══════════════════════════════════════════
print_step 4 "Clonando repositorios de Bemovil 2.0..."

declare -A REPOS=(
  ["backend"]="https://github.com/IT-Bemovil/bemovil2.0-backend.git|master"
  ["frontend"]="https://github.com/IT-Bemovil/bemovil2.0-frontend.git|main"
  ["admin"]="https://github.com/IT-Bemovil/bemovil2.0-frontend-admin.git|main"
  ["bemovil2-proxy"]="https://github.com/IT-Bemovil/bemovil2-proxy.git|main"
)

declare -A ENV_FILES=(
  ["backend"]="backend.env"
  ["frontend"]="frontend.env"
  ["admin"]="admin.env"
  ["bemovil2-proxy"]="proxy.env"
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
  else
    print_warn "$dir: no se pudo clonar (¿sin acceso al repo?)"
    FAILED_REPOS+=("$dir")
    WARNINGS+=("No se pudo clonar $dir. Verifica tu acceso a $repo_url")
  fi
done

# Create .env templates for all repo dirs (cloned or pre-existing)
echo ""
print_info "Creando plantillas de variables de entorno..."
for dir in backend frontend admin bemovil2-proxy; do
  target_path="$TARGET_DIR/$dir"
  env_file="${ENV_FILES[$dir]:-}"
  if [ -d "$target_path" ] && [ -n "$env_file" ] && [ ! -f "$target_path/.env" ]; then
    if [ -f "$SCRIPT_DIR/env-templates/$env_file" ]; then
      cp "$SCRIPT_DIR/env-templates/$env_file" "$target_path/.env"
      print_ok ".env plantilla creada en $dir/"
    fi
  elif [ -d "$target_path" ] && [ -f "$target_path/.env" ]; then
    print_info ".env de $dir ya existe, no se sobreescribe"
  fi
done

# ═══════════════════════════════════════════
# STEP 5: Install Bemovil-specific extras
# ═══════════════════════════════════════════
print_step 5 "Instalando herramientas específicas de Bemovil..."

# ── E2E Forge ──
echo ""
print_info "Instalando E2E Forge..."
E2E_TMP="/tmp/e2e-forge-install"
rm -rf "$E2E_TMP"

if git clone --depth 1 https://github.com/thestark77/e2e-forge.git "$E2E_TMP" 2>/dev/null; then
  if [ -f "$E2E_TMP/install.sh" ]; then
    bash "$E2E_TMP/install.sh"
    print_ok "E2E Forge instalado"
  else
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

# ── Caveman skill (Bemovil uses it, not in stark-kit) ──
echo ""
print_info "Instalando skill: caveman..."
if claude skill install "github:JuliusBrussee/caveman" 2>/dev/null; then
  print_ok "caveman instalado"
else
  print_info "caveman ya instalado o no disponible"
fi

# ── Linear MCP (task management) ──
echo ""
print_info "Configurando MCP: linear-server..."
if claude mcp add linear-server --transport sse --url "https://mcp.linear.app/sse" 2>/dev/null; then
  print_ok "linear-server MCP configurado (requiere autenticación)"
else
  print_info "linear-server ya configurado o no disponible"
fi

# ═══════════════════════════════════════════
# STEP 6: Finalize
# ═══════════════════════════════════════════
print_step 6 "Finalizando configuración..."

cd "$TARGET_DIR" || return 1

if [ ! -d ".git" ]; then
  git init -q
  git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json feedback/ 2>/dev/null
  git add opencode.json opencode.md 2>/dev/null
  git commit -q -m "init: be-code-kit setup (via stark-kit)"
  print_ok "Repositorio raíz inicializado"
else
  print_info "Repositorio raíz ya existe"
fi

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
echo -e "  ${BOLD}Instalado via:${NC} stark-kit → autoSDD → Bemovil config"
echo ""

if [ ${#CLONED_REPOS[@]} -gt 0 ]; then
  echo -e "  ${GREEN}Repositorios:${NC}"
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
echo -e "    3. Abrí tu agente de IA:"
echo -e "       Claude Code: cd $TARGET_DIR && claude"
echo -e "       OpenCode:    cd $TARGET_DIR && opencode"
echo -e "    4. Configura Axiom: pega el AXIOM_QUERY_TOKEN en backend/.env"
echo ""
echo -e "  ${BOLD}Lee el README.md para el tutorial completo.${NC}"
echo ""

}

_becode_install "$@"
