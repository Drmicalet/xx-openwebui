#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# entrypoint-xx-openwebui.sh v223
# ───────────────────────────────────────────────────────────────────────────
# Entrypoint SOLO para open-webui v3 (adelgazado).
# Igual que v2 pero puerto 8080.
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

log()  { echo "[openwebui] $*"; }
warn() { echo "[openwebui] WARN: $*"; }
err()  { echo "[openwebui] ERROR: $*" >&2; }

log "=== xx-openwebui v223 (adelgazado) ==="
log "  OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-http://127.0.0.1:11434}"
log "  WEBUI port: ${PORT:-8080}"
log ""

# ─── 1. Crear directorios necesarios ─────────────────────────────────────
mkdir -p "${DATA_DIR:-/app/data}" "${TMPDIR:-/casa/tmp}"
mkdir -p "${DATA_DIR:-/app/data}/models" "${DATA_DIR:-/app/data}/huggingface" 2>/dev/null || true

# ─── 2. Verificar que xx-ollama responde (con reintentos) ────────────────
log "Verificando conexión con xx-ollama (${OLLAMA_BASE_URL:-http://127.0.0.1:11434})..."
OLLAMA_OK=false
for i in $(seq 1 30); do
    if curl -fsS "${OLLAMA_BASE_URL:-http://127.0.0.1:11434}/api/tags" >/dev/null 2>&1; then
        log "  ✓ xx-ollama disponible tras ${i}*2 segundos"
        OLLAMA_OK=true
        break
    fi
    sleep 2
done

if [ "$OLLAMA_OK" = "false" ]; then
    warn "  ⚠ xx-ollama no responde — continuando igualmente (open-webui es resiliente)"
fi

# ─── 3. Lanzar open-webui en FOREGROUND (exec para ser PID 1) ─────────────
log ""
log "Iniciando open-webui v3 en foreground (puerto ${PORT:-8080})..."

OPENWEBUI_BIN="/opt/openwebui-venv/bin/open-webui"

if [[ ! -x "$OPENWEBUI_BIN" ]]; then
    err "ERROR: open-webui no encontrado en $OPENWEBUI_BIN"
    err "  ¿Se construyó correctamente el Containerfile?"
    err "  ¿Se rompió algo durante la limpieza de v3?"
    exit 1
fi

log "  Binario: $OPENWEBUI_BIN"
log "  Versión: $($OPENWEBUI_BIN --version 2>&1 | head -1)"
log ""

case "${1:-serve}" in
    shell)
        log "Dropping to shell..."
        exec /bin/bash
        ;;
    serve|*)
        exec "$OPENWEBUI_BIN" serve \
            --host 0.0.0.0 \
            --port "${PORT:-8080}"
        ;;
esac
