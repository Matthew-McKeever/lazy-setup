#!/usr/bin/env bash
# Arch Linux recovery bootstrap: Python, Go, Java, Node (+ managers)
# Run as your normal user. The script uses sudo where needed.

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/versions.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Missing versions.conf — create one before running."
  exit 1
fi

### ───────────────────────── helpers ─────────────────────────
section() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
notice()  { printf "\033[0;33m[!] %s\033[0m\n" "$*"; }
ok()      { printf "\033[0;32m[ok]\033[0m %s\n" "$*"; }

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  notice "Run this as a normal user, not root. I'll sudo when needed."
fi

# Cache sudo early
sudo -v || { echo "sudo required"; exit 1; }

### ───────────────────────── system deps ─────────────────────────
section "Updating pacman and installing base tools"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
  base-devel git curl wget unzip zip tar jq pkgconf \
  gnupg lsb-release

ok "Base tools installed"

### ───────────────────────── Node (NVM + Corepack) ─────────────────────────
section "Installing Node via NVM and enabling Corepack (pnpm/yarn)"
if [[ -z "${NVM_VERSION:-}" ]]; then
  echo "NVM_VERSION must be set in versions.conf" >&2
  exit 1
fi

if [[ ! -d "${HOME}/.nvm" ]]; then
  nvm_tag="${NVM_VERSION}"
  [[ "$nvm_tag" == v* ]] || nvm_tag="v${nvm_tag}"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_tag}/install.sh" | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if [[ -z "${NODE_VERSION:-}" ]]; then
  echo "NODE_VERSION must be set in versions.conf" >&2
  exit 1
fi

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION" >/dev/null 2>&1 || true
corepack enable || true
corepack prepare pnpm@latest --activate || true
corepack prepare yarn@stable --activate || true

ok "Node: $(node -v 2>/dev/null || echo missing), npm: $(npm -v 2>/dev/null || echo missing), pnpm: $(pnpm -v 2>/dev/null || echo missing), yarn: $(yarn -v 2>/dev/null || echo missing)"

### ───────────────────────── Go (tarball) ─────────────────────────
section "Installing Go (official tarball)"
if [[ -z "${GO_VERSION:-}" ]]; then
  echo "GO_VERSION must be set in versions.conf" >&2
  exit 1
fi

GO_TGZ="go${GO_VERSION}.linux-amd64.tar.gz"

if [[ -d /usr/local/go ]]; then
  sudo rm -rf /usr/local/go
fi

if [[ ! -f "/tmp/${GO_TGZ}" ]]; then
  curl -fsSL -o "/tmp/${GO_TGZ}" "https://go.dev/dl/${GO_TGZ}"
fi

sudo tar -C /usr/local -xzf "/tmp/${GO_TGZ}"

if ! grep -q '/usr/local/go/bin' "${HOME}/.bashrc"; then
  {
    echo "export GOPATH=\"\$HOME/go\""
    echo "export PATH=\"/usr/local/go/bin:\$GOPATH/bin:\$PATH\""
  } >> "${HOME}/.bashrc"
  ok "Added Go PATH and GOPATH to .bashrc"
fi

export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

ok "Go: $(go version 2>/dev/null || echo missing)"

### ───────────────────────── Java (SDKMAN) ─────────────────────────
section "Installing Java via SDKMAN"
if [[ ! -d "${HOME}/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
fi
set +u
source "${HOME}/.sdkman/bin/sdkman-init.sh"

if [[ -z "${JAVA_VERSION:-}" ]]; then
  echo "JAVA_VERSION must be set in versions.conf" >&2
  exit 1
fi

sdk install java "$JAVA_VERSION"
sdk default java "$JAVA_VERSION"
set -u

ok "Java: $(java -version 2>&1 | head -n1 || echo missing)"

### ───────────────────────── Neovim ─────────────────────────
section "Installing Neovim"
NEOVIM_VERSION="${NEOVIM_VERSION:-0.11.5}"
nvim_arch="$(uname -m)"
case "$nvim_arch" in
  x86_64|amd64)
    NVIM_TGZ="nvim-linux-x86_64.tar.gz"
    ;;
  arm64|aarch64)
    NVIM_TGZ="nvim-linux-arm64.tar.gz"
    ;;
  *)
    echo "Unsupported architecture: $nvim_arch" >&2
    exit 1
    ;;
esac
NVIM_DIR="${NVIM_TGZ%.tar.gz}"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${NVIM_TGZ}"

if [[ ! -f "/tmp/${NVIM_TGZ}" ]]; then
  curl -fsSL -o "/tmp/${NVIM_TGZ}" "${NVIM_URL}"
fi

if [[ -d "/usr/local/${NVIM_DIR}" ]]; then
  sudo rm -rf "/usr/local/${NVIM_DIR}"
fi

sudo tar -C /usr/local -xzf "/tmp/${NVIM_TGZ}"
sudo ln -sf "/usr/local/${NVIM_DIR}/bin/nvim" /usr/local/bin/nvim

ok "Neovim: $(nvim --version 2>/dev/null | head -n1 || echo missing)"

### ───────────────────────── post-check ─────────────────────────
section "Versions summary"
echo "Node (${NODE_VERSION:-unset}):   $(node -v 2>/dev/null || echo missing)"
echo "npm:    $(npm -v 2>/dev/null || echo missing)"
echo "pnpm:   $(pnpm -v 2>/dev/null || echo missing)"
echo "yarn:   $(yarn -v 2>/dev/null || echo missing)"
echo "Go:     $(go version 2>/dev/null || echo missing)"
echo "Java:   $(java -version 2>&1 | head -n1 || echo missing)"
echo "Neovim: $(nvim --version 2>/dev/null | head -n1 || echo missing)"

section "Done"
echo "Open a new terminal or run:  exec bash -l"

