#!/usr/bin/env bash
# Linux Mint recovery bootstrap: Python, Go, Java, Node (+ managers)
# Run as your normal user. The script uses sudo where needed.

set -euo pipefail

#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$(dirname "$0")/versions.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1091
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
section "Updating APT and installing base tools"
sudo apt-get update -y
sudo apt-get install -y \
  build-essential git curl wget ca-certificates gnupg lsb-release \
  unzip zip tar jq pkg-config software-properties-common

ok "Base tools installed"

### ───────────────────────── Python ─────────────────────────
section "Installing Python, pip, venv, pipx"
sudo apt-get install -y python3 python3-pip python3-venv pipx
# Ensure pipx on PATH
if ! grep -q 'export PATH=.*/.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
  ok "Added ~/.local/bin to PATH in .bashrc"
fi
ok "Python: $(python3 --version 2>/dev/null || echo missing), pipx: $(pipx --version 2>/dev/null || echo missing)"

### ───────────────────────── Node (NVM + Corepack) ─────────────────────────
section "Installing Node via NVM and enabling Corepack (pnpm/yarn)"
# NVM install if missing
if ! command -v nvm >/dev/null 2>&1; then
  export NVM_VERSION="v0.39.7"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# Shell hooks for current session
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install latest LTS and set default
nvm install --lts
nvm alias default 'lts/*'
# Enable Corepack-managed pm (pnpm, yarn)
corepack enable || true
corepack prepare pnpm@latest --activate || true
corepack prepare yarn@stable --activate || true

ok "Node: $(node -v 2>/dev/null || echo missing), npm: $(npm -v 2>/dev/null || echo missing), pnpm: $(pnpm -v 2>/dev/null || echo missing), yarn: $(yarn -v 2>/dev/null || echo missing)"

### ───────────────────────── Go (tarball) ─────────────────────────
section "Installing Go (official tarball)"
GO_VERSION="${GO_VERSION:-1.23.3}"   # change if you want a specific version
GO_TGZ="go${GO_VERSION}.linux-amd64.tar.gz"

# Remove old /usr/local/go if present
if [[ -d /usr/local/go ]]; then
  sudo rm -rf /usr/local/go
fi

# Download to /tmp if not already there
if [[ ! -f "/tmp/${GO_TGZ}" ]]; then
  curl -fsSL -o "/tmp/${GO_TGZ}" "https://go.dev/dl/${GO_TGZ}"
fi

sudo tar -C /usr/local -xzf "/tmp/${GO_TGZ}"

# Ensure PATH and GOPATH
if ! grep -q '/usr/local/go/bin' "${HOME}/.bashrc"; then
  {
    echo 'export GOPATH="$HOME/go"'
    echo 'export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"'
  } >> "${HOME}/.bashrc"
  ok "Added Go PATH and GOPATH to .bashrc"
fi

# Make current session aware
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

ok "Go: $(go version 2>/dev/null || echo missing)"

### ───────────────────────── Java (SDKMAN + Temurin 21) ─────────────────────────
section "Installing Java via SDKMAN (Temurin 21 LTS)"
if [[ ! -d "${HOME}/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
fi
# shellcheck disable=SC1090
source "${HOME}/.sdkman/bin/sdkman-init.sh"

# Install Temurin 21 (LTS)
if ! sdk current java | grep -q '21'; then
  # List identifiers: sdk list java | grep -i temurin
  sdk install java 21-tem || sdk install java 21.0.*/temurin || true
  sdk default java || true
fi

ok "Java: $(java -version 2>&1 | head -n1 || echo missing)"

### ───────────────────────── post-check ─────────────────────────
section "Versions summary"
echo "Python: $(python3 --version 2>/dev/null || echo missing)"
echo "pipx:   $(pipx --version 2>/dev/null || echo missing)"
echo "Node:   $(node -v 2>/dev/null || echo missing)"
echo "npm:    $(npm -v 2>/dev/null || echo missing)"
echo "pnpm:   $(pnpm -v 2>/dev/null || echo missing)"
echo "yarn:   $(yarn -v 2>/dev/null || echo missing)"
echo "Go:     $(go version 2>/dev/null || echo missing)"
echo "Java:   $(java -version 2>&1 | head -n1 || echo missing)"

section "Done"
echo "Open a new terminal or run:  exec bash -l"


