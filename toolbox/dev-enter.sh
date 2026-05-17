#!/bin/bash
# dev-enter.sh — hardened wrapper for toolbox container 'dev'
#
# Security model (with --privileged constraint):
#   - Sensitive dirs mounted read-only (no writes, but readable)
#   - Sensitive files masked via /dev/null bind-mount (unreadable)
#   - TMPDIR redirected to /var/home to fix Silverblue composefs issue
#
# Note: --privileged is required by toolbox init-container.
# It overrides --security-opt no-new-privileges, so that flag is omitted.
# The real protection is read-only mounts + VSCode sandbox (chat.agent.sandbox).
#
# Usage:
#   ~/.config/toolbox/dev-enter.sh                 # create if needed, then enter
#   ~/.config/toolbox/dev-enter.sh --build         # rebuild the dev-toolbox image
#   ~/.config/toolbox/dev-enter.sh --destroy       # remove container for current project (or 'dev')
#   ~/.config/toolbox/dev-enter.sh --destroy --all # remove ALL dev-* containers
#   ~/.config/toolbox/dev-enter.sh --list          # list all dev-* containers with status

set -euo pipefail

IMAGE="localhost/dev-toolbox:latest"
HOME_DIR="/var/home/vicente"
PODMAN="${PODMAN:-$(command -v podman 2>/dev/null || echo /run/host/usr/bin/podman)}"
MASKS_DIR="${HOME_DIR}/tmp/masks"
TOOLBOX_PATH="${TOOLBOX_PATH:-/usr/bin/toolbox}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# ── Slug derivation: derive per-project container name ────────
GIT_ROOT=$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$GIT_ROOT" ]]; then
  PROJECT_SLUG=$(basename "$GIT_ROOT")
  CONTAINER="dev-${PROJECT_SLUG}"
  PROJECT_DIR="$GIT_ROOT"
  SCOPED=true
else
  CONTAINER="dev"
  SCOPED=false
  PROJECT_DIR=""
fi

# ── Fix Silverblue composefs "no space left" ──────────────────
# crun resolves TMPDIR for overlay operations. Without this,
# it tries to write to composefs root (always 100% "full").
export TMPDIR="${HOME_DIR}/tmp"
mkdir -p "$TMPDIR"

# ── Sensitive dirs: empty read-only bind-mounts ───────────────
# tmpfs on subdir of a mounted volume fails on Silverblue (crun bug).
# Solution: bind-mount empty dirs from $HOME/tmp/masks instead.
# Effect: dirs appear empty AND are read-only inside the container.
mkdir -p "${MASKS_DIR}"/{ssh,gnupg,pki,putty,secrets}
chmod 700 "${MASKS_DIR}"/{ssh,gnupg,pki,putty,secrets}

MASKED_DIRS=(
  "${MASKS_DIR}/ssh:${HOME_DIR}/.ssh"
  "${MASKS_DIR}/gnupg:${HOME_DIR}/.gnupg"
  "${MASKS_DIR}/pki:${HOME_DIR}/.pki"
  "${MASKS_DIR}/putty:${HOME_DIR}/.putty"
  "${MASKS_DIR}/secrets:${HOME_DIR}/secrets"
)

# Files masked via /dev/null bind-mount (renders file empty + read-only)
MASKED_FILES=(
  "${HOME_DIR}/.npmrc"
  "${HOME_DIR}/.kagi.toml"
)

# ── Build volume flags ────────────────────────────────────────
build_volume_flags() {
  local -n _flags=$1

  _flags=(
    "--volume" "/:/run/host:rslave"
    "--volume" "/dev:/dev:rslave"
    "--volume" "${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}:rslave"
    "--volume" "${TOOLBOX_PATH}:/usr/bin/toolbox:ro"
  )

  if [[ "$SCOPED" == true ]]; then
    # Scoped mount: project dir + explicit tool allowlist
    local SCOPED_VOLUMES=(
      "${HOME_DIR}/.volta"
      "${HOME_DIR}/.bun"
      "${HOME_DIR}/.cargo"
      "${HOME_DIR}/.deno"
      "${HOME_DIR}/.go"
      "${HOME_DIR}/.cache/go-build"
      "${HOME_DIR}/.local/share/pnpm"
      "${HOME_DIR}/.local/bin"
      "${HOME_DIR}/.cache"
      "${HOME_DIR}/.config"
      "${HOME_DIR}/.engram"
      "${HOME_DIR}/.agents"
      "${HOME_DIR}/tmp"
    )

    # Mount project dir
    _flags+=("--volume" "${PROJECT_DIR}:${PROJECT_DIR}:rw")

    # Mount each allowlist entry only if it exists on the host
    for dir in "${SCOPED_VOLUMES[@]}"; do
      [[ -d "$dir" ]] && _flags+=("--volume" "${dir}:${dir}:rw")
    done
  else
    # Legacy: full $HOME mount (backward compatibility)
    _flags+=("--volume" "${HOME_DIR}:${HOME_DIR}:rslave")
  fi

  # Masked dirs: empty dir overrides (read-only, appear empty)
  for mapping in "${MASKED_DIRS[@]}"; do
    local src="${mapping%%:*}"
    local dst="${mapping##*:}"
    _flags+=("--volume" "${src}:${dst}:ro")
  done

  # Masked files: /dev/null override
  for file in "${MASKED_FILES[@]}"; do
    _flags+=("--volume" "/dev/null:${file}:ro")
  done
}

# ── Commands ──────────────────────────────────────────────────
case "${1:-run}" in
  --build)
    echo "[dev-toolbox] Building image '${IMAGE}'..."
    CONTAINERFILE="${HOME_DIR}/.config/toolbox/Containerfile"
    TMPDIR="${HOME_DIR}/tmp" $PODMAN build -f "$CONTAINERFILE" -t "$IMAGE" "${HOME_DIR}/.config/toolbox"
    echo "[dev-toolbox] Build complete."
    ;;

  --destroy)
    if [[ "${2:-}" == "--all" ]]; then
      echo "[dev-toolbox] Removing all dev-* containers..."
      ids=$($PODMAN ps -a --filter 'name=^dev-' -q 2>/dev/null || true)
      [[ -n "$ids" ]] && $PODMAN rm -f $ids
      toolbox rm -f dev 2>/dev/null || true
      echo "Done."
    else
      echo "[dev-toolbox] Removing container '${CONTAINER}'..."
      toolbox rm -f "$CONTAINER" 2>/dev/null || $PODMAN rm -f "$CONTAINER" 2>/dev/null || true
      echo "Done."
    fi
    ;;

  --list)
    $PODMAN ps -a --filter label=com.github.containers.toolbox=true \
      --format 'table {{.Names}}\t{{.Status}}'
    ;;

  run|"")
    if ! $PODMAN container exists "$CONTAINER" 2>/dev/null; then
      echo "[dev-toolbox] Creating container '${CONTAINER}'..."

      VOLUME_FLAGS=()
      build_volume_flags VOLUME_FLAGS

      TMPDIR="${HOME_DIR}/tmp" $PODMAN create \
        --name "$CONTAINER" \
        --label "com.github.containers.toolbox=true" \
        --cgroupns host \
        --dns none \
        --hostname toolbx \
        --ipc host \
        --network host \
        --no-hosts \
        --pid host \
        --privileged \
        --security-opt label=disable \
        --ulimit host \
        --userns keep-id \
        --user root:root \
        --mount type=devpts,destination=/dev/pts \
        --env "TOOLBOX_PATH=${TOOLBOX_PATH}" \
        --env "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" \
        "${VOLUME_FLAGS[@]}" \
        "$IMAGE" \
        toolbox --log-level debug init-container \
          --gid "$(id -g)" \
          --home "${HOME_DIR}" \
          --shell /bin/bash \
          --uid "$(id -u)" \
          --user "$(id -un)"

      echo "[dev-toolbox] Container '${CONTAINER}' created."
    fi

    # Start if not running
    if ! $PODMAN ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
      TMPDIR="${HOME_DIR}/tmp" $PODMAN start "$CONTAINER"
    fi

    # Use caller's CWD if it exists inside the container, else fall back to home
    WORKDIR="${PWD:-${HOME_DIR}}"
    [[ "$WORKDIR" == / || ! -d "$WORKDIR" ]] && WORKDIR="${HOME_DIR}"

    exec $PODMAN exec -it --user "$(id -un)" --workdir "$WORKDIR" "$CONTAINER" /bin/bash -l
    ;;

  # Non-interactive exec — used by opencode shell and scripts.
  # Usage: dev-enter.sh -c "command"
  -c)
    shift
    if ! $PODMAN container exists "$CONTAINER" 2>/dev/null; then
      echo "[dev-toolbox] Container '${CONTAINER}' does not exist. Run dev-enter.sh first." >&2
      exit 1
    fi
    if ! $PODMAN ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
      TMPDIR="${HOME_DIR}/tmp" $PODMAN start "$CONTAINER"
    fi

    WORKDIR="${PWD:-${HOME_DIR}}"
    [[ "$WORKDIR" == / || ! -d "$WORKDIR" ]] && WORKDIR="${HOME_DIR}"

    exec $PODMAN exec --user "$(id -un)" --workdir "$WORKDIR" \
      ${KAGI_SESSION_TOKEN:+--env "KAGI_SESSION_TOKEN=${KAGI_SESSION_TOKEN}"} \
      "$CONTAINER" /bin/bash -l -c "$*"
    ;;

  *)
    echo "Usage: $0 [--build | --destroy [--all] | --list | -c <command>]"
    exit 1
    ;;
esac
