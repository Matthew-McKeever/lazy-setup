#!/usr/bin/env bash
# Linux Mint recovery bootstrap: Python, Go, Java, Node (+ managers)
# Run as your normal user. The script uses sudo where needed.

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/versions.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=linux/mint/versions.conf
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
python_pkgs=(python3 python3-pip pipx)
selected_python_pkg="python3"
selected_python_cmd="python3"
selected_python_venv_pkg="python3-venv"

if [[ -n "${PYTHON_VERSION:-}" ]]; then
  candidate_python_pkg="python${PYTHON_VERSION}"
  if apt-cache show "$candidate_python_pkg" >/dev/null 2>&1; then
    selected_python_pkg="$candidate_python_pkg"
    selected_python_cmd="$candidate_python_pkg"
    candidate_python_venv_pkg="${candidate_python_pkg}-venv"
    if apt-cache show "$candidate_python_venv_pkg" >/dev/null 2>&1; then
      selected_python_venv_pkg="$candidate_python_venv_pkg"
    else
      notice "${candidate_python_venv_pkg} not available; falling back to python3-venv"
    fi
  else
    notice "${candidate_python_pkg} not available via APT; falling back to python3"
  fi
else
  notice "PYTHON_VERSION not set; installing distro python3"
fi

python_pkgs+=("$selected_python_pkg" "$selected_python_venv_pkg")
sudo apt-get install -y "${python_pkgs[@]}"

# Ensure pipx on PATH
if ! grep -q 'export PATH=.*/.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "${HOME}/.bashrc"
  ok "Added ~/.local/bin to PATH in .bashrc"
fi
ok "Python (${selected_python_cmd}): $(command -v "$selected_python_cmd" >/dev/null 2>&1 && "$selected_python_cmd" --version 2>/dev/null || echo missing), pipx: $(pipx --version 2>/dev/null || echo missing)"

### ───────────────────────── Node (NVM + Corepack) ─────────────────────────
section "Installing Node via NVM and enabling Corepack (pnpm/yarn)"
if [[ -z "${NVM_VERSION:-}" ]]; then
  echo "NVM_VERSION must be set in versions.conf" >&2
  exit 1
fi

# NVM install if missing
if [[ ! -d "${HOME}/.nvm" ]]; then
  nvm_tag="${NVM_VERSION}"
  [[ "$nvm_tag" == v* ]] || nvm_tag="v${nvm_tag}"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_tag}/install.sh" | bash
fi

# Shell hooks for current session
export NVM_DIR="$HOME/.nvm"
# shellcheck source=ci-stubs/nvm.sh
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if [[ -z "${NODE_VERSION:-}" ]]; then
  echo "NODE_VERSION must be set in versions.conf" >&2
  exit 1
fi

nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION" >/dev/null 2>&1 || true
# Enable Corepack-managed pm (pnpm, yarn)
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
    echo "export GOPATH=\"\$HOME/go\""
    echo "export PATH=\"/usr/local/go/bin:\$GOPATH/bin:\$PATH\""
  } >> "${HOME}/.bashrc"
  ok "Added Go PATH and GOPATH to .bashrc"
fi

# Make current session aware
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

ok "Go: $(go version 2>/dev/null || echo missing)"

### ───────────────────────── Java (SDKMAN) ─────────────────────────
section "Installing Java via SDKMAN"
if [[ ! -d "${HOME}/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
fi
# SDKMAN init script references several variables before defining them, which
# trips `set -u`. Temporarily relax undefined-variable checks while sourcing.
set +u
# shellcheck source=ci-stubs/sdkman-init.sh
source "${HOME}/.sdkman/bin/sdkman-init.sh"
set -u

# Install configured Java distribution
if [[ -z "${JAVA_VERSION:-}" ]]; then
  echo "JAVA_VERSION must be set in versions.conf" >&2
  exit 1
fi

sdk install java "$JAVA_VERSION"
sdk default java "$JAVA_VERSION"

ok "Java: $(java -version 2>&1 | head -n1 || echo missing)"

### ───────────────────────── Neovim ─────────────────────────
section "Installing Neovim"
NEOVIM_VERSION="${NEOVIM_VERSION:-0.12.0}"
NVIM_TGZ="nvim-linux64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${NVIM_TGZ}"

# Fetch tarball
if [[ ! -f "/tmp/${NVIM_TGZ}" ]]; then
  curl -fsSL -o "/tmp/${NVIM_TGZ}" "${NVIM_URL}"
fi

# Remove any existing install to avoid stale binaries
if [[ -d /usr/local/nvim-linux64 ]]; then
  sudo rm -rf /usr/local/nvim-linux64
fi

# Extract fresh copy under /usr/local
sudo tar -C /usr/local -xzf "/tmp/${NVIM_TGZ}"

# Ensure nvim is on PATH
sudo ln -sf /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim

ok "Neovim: $(nvim --version 2>/dev/null | head -n1 || echo missing)"

### ───────────────────────── post-check ─────────────────────────
section "Versions summary"
echo "Python (${selected_python_cmd}): $(command -v "$selected_python_cmd" >/dev/null 2>&1 && "$selected_python_cmd" --version 2>/dev/null || echo missing)"
echo "pipx:   $(pipx --version 2>/dev/null || echo missing)"
echo "Node (${NODE_VERSION:-unset}):   $(node -v 2>/dev/null || echo missing)"
echo "npm:    $(npm -v 2>/dev/null || echo missing)"
echo "pnpm:   $(pnpm -v 2>/dev/null || echo missing)"
echo "yarn:   $(yarn -v 2>/dev/null || echo missing)"
echo "Go:     $(go version 2>/dev/null || echo missing)"
echo "Java:   $(java -version 2>&1 | head -n1 || echo missing)"
echo "Neovim: $(nvim --version 2>/dev/null | head -n1 || echo missing)"

section "Done"
echo "Open a new terminal or run:  exec bash -l"


