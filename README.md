# xx-openwebui

> **Base image:** `ghcr.io/drmicalet/xx-xinoxano:latest`
> **Image:** `ghcr.io/drmicalet/xx-openwebui:latest`
> **Port(s):** 8080 (Open WebUI HTTP)
> **License:** LGPL-3.0

---

## Overview

### English

Open WebUI — the main chat interface. Fork of Ollama WebUI with multi-model support, RAG, functions, users and RBAC. Installed with uv pip install open-webui in a dedicated Python 3.12 venv (/opt/openwebui-venv). Connects to Ollama via OLLAMA_BASE_URL=http://127.0.0.1:11434. Entrypoint uses bash pattern (entrypoint.sh), NOT direct /usr/bin/tini invocation.

### Castellano

Open WebUI — la interfaz principal de chat. Fork de Ollama WebUI con soporte multi-modelo, RAG, funciones, usuarios y RBAC. Instalado con uv pip install open-webui en un venv dedicado de Python 3.12 (/opt/openwebui-venv). Se conecta a Ollama vía OLLAMA_BASE_URL=http://127.0.0.1:11434. El entrypoint usa patrón bash (entrypoint.sh), NO invocación directa de /usr/bin/tini.

### Català

Open WebUI — la interfície principal de chat. Fork d'Ollama WebUI amb suport multi-model, RAG, funcions, usuaris i RBAC. Instal·lat amb uv pip install open-webui en un venv dedicat de Python 3.12 (/opt/openwebui-venv). Es connecta a Ollama via OLLAMA_BASE_URL=http://127.0.0.1:11434. L'entrypoint usa patró bash (entrypoint.sh), NO invocació directa de /usr/bin/tini.

---

## Pull

```bash
podman pull ghcr.io/drmicalet/xx-openwebui:latest
# or
docker pull ghcr.io/drmicalet/xx-openwebui:latest
```

## Run

### Podman

```bash
podman run -d \
  --name xx-openwebui \
  ghcr.io/drmicalet/xx-openwebui:latest
```

### Docker

```bash
docker run -d \
  --name xx-openwebui \
  ghcr.io/drmicalet/xx-openwebui:latest
```

### Kubernetes / K3s

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: xx-openwebui
spec:
  containers:
  - name: xx-openwebui
    image: ghcr.io/drmicalet/xx-openwebui:latest
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 8080
```

---

### Files in this repo

| File | Purpose |
|------|---------|
| `Containerfile` | Docker/Podman build definition |
| `entrypoint.sh` | Bash entrypoint script (ENTRYPOINT) |
| `README.md` | This document |
| `LICENSE` | LGPL-3.0 license |
| `.gitignore` | Git ignore rules |

---

## Entrypoint

The container uses `entrypoint.sh` (bash pattern) as ENTRYPOINT, NOT direct binary invocation with `/usr/bin/tini`. This pattern:
- Verifies dependencies before starting
- Uses `case $1 in` for subcommands
- Ends with `exec` to make the main process PID 1

```dockerfile
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["serve"]
```

---

## Build from source

```bash
git clone https://github.com/Drmicalet/xx-openwebui.git
cd xx-openwebui
podman build --network host -t ghcr.io/drmicalet/xx-openwebui:latest -f Containerfile .
```

---

## License

LGPL-3.0 — same as Arch Linux packages.

## Author

drmicalet — https://github.com/Drmicalet
