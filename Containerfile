# ═══════════════════════════════════════════════════════════════════════════
# Containerfile.xx-openwebui  v223
# ───────────────────────────────────────────────────────────────────────────
# Container SOLO open-webui, ADELGAZADO desde xx-openwebui-v2 (que sabemos que funciona).
#
# ESTRATEGIA:
#   1. FROM localhost/xx-openwebui-v2:latest (hereda open-webui venv funcional)
#   2. Desinstalar paquetes innecesarios:
#      - Drivers Vulkan (vulkan-radeon, vulkan-icd-loader, vulkan-tools) — ~500MB
#      - yay y deps de build (si se instalaron)
#      - Cache de pacman (/var/cache/pacman/pkg/*)
#      - /data/ollama (vacío, heredado)
#      - /tmp/cachyos-pkgs/ (si existe)
#   3. Verificar que open-webui sigue funcionando tras la limpieza
#
# OBJETIVO: tamaño similar a xx-openwebui original, pero funcional
#
# PUERTO: 8080 (distinto de 8080 y 8280 para no chocar)
# ═══════════════════════════════════════════════════════════════════════════
FROM localhost/xx-openwebui-v2:latest
LABEL version="v223" \
      description="xx-openwebui — open-webui adelgazado, basado en v2 funcional" \
      maintainer="drmicalet"

USER root

# ─── 1. Desinstalar drivers Vulkan (no se necesitan para open-webui solo) ──
# open-webui habla con xx-ollama via HTTP, no usa Vulkan directamente
RUN set -uo pipefail && \
    echo "=== Desinstalando drivers Vulkan ===" && \
    pacman -R --noconfirm \
        vulkan-radeon \
        vulkan-icd-loader \
        vulkan-tools \
        2>/dev/null || true && \
    echo "✓ Drivers Vulkan desinstalados (si existían)"

# ─── 2. Desinstalar yay (compilador AUR, no se necesita en runtime) ──────
RUN set -uo pipefail && \
    echo "=== Desinstalando yay y deps de build ===" && \
    pacman -R --noconfirm yay \
        base-devel \
        git \
        2>/dev/null || true && \
    # git puede ser necesario para clonar configs, lo reinstalamos si se desinstaló
    command -v git >/dev/null 2>&1 || pacman -S --noconfirm --needed git 2>/dev/null || true && \
    echo "✓ yay y base-devel desinstalados"

# ─── 3. Limpiar cache de pacman y directorios vacíos ────────────────────
RUN set -uo pipefail && \
    echo "=== Limpieza de cache ===" && \
    # Cache de paquetes descargados
    pacman -Scc --noconfirm 2>/dev/null || true && \
    rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/* 2>/dev/null || true && \
    # Directorios vacíos heredados de xx-ollama
    rm -rf /data/ollama /tmp/cachyos-pkgs 2>/dev/null || true && \
    # Logs de ollama si existen
    rm -f /var/log/ollama.log 2>/dev/null || true && \
    # __pycache__ del venv (se regeneran al arrancar)
    find /opt/openwebui-venv -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true && \
    # .pyc files
    find /opt/openwebui-venv -name '*.pyc' -delete 2>/dev/null || true && \
    echo "✓ Limpieza completa"

# ─── 4. Verificar que open-webui sigue funcionando ───────────────────────
RUN set -uo pipefail && \
    echo "=== Verificación post-limpieza ===" && \
    OPENWEBUI_BIN=/opt/openwebui-venv/bin/open-webui && \
    if [[ ! -x "$OPENWEBUI_BIN" ]]; then \
        echo "✗✗✗ ERROR: open-webui no encontrado tras limpieza ✗✗✗" && \
        exit 1; \
    fi && \
    $OPENWEBUI_BIN --version 2>&1 | head -3 || \
    /opt/openwebui-venv/bin/python -c "import open_webui; print('open_webui ok')" && \
    echo "✓ open-webui funciona tras limpieza"

# ─── 5. Variables de entorno ─────────────────────────────────────────────
ENV OLLAMA_BASE_URL="http://127.0.0.1:11434" \
    DATA_DIR="/app/data" \
    OPENWEBUI_DATA_DIR="/app/data" \
    WEBUI_SECRET_KEY="flor-mlai-v223" \
    PORT="8080" \
    HOST="0.0.0.0" \
    ENABLE_RAG="false" \
    WEBUI_AUTH="false" \
    TMPDIR="/casa/tmp" \
    PATH="/opt/openwebui-venv/bin:${PATH}"

EXPOSE 8080
VOLUME ["/app/data", "/casa/tmp"]

# ─── 6. Copiar entrypoint (mismo que v2, solo cambia el puerto por defecto) ──
COPY entrypoint-xx-openwebui.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ─── 7. Healthcheck ──────────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -fsS http://127.0.0.1:8080/health || exit 1

USER ollama

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["serve"]
