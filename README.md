# lazy-setup

`lazy-setup` is my reproducible workstation kit: a Linux Mint bootstrapper that installs pinned language runtimes plus a curated NeoVim setup wired through Lazy.nvim. Everything lives in this repo so I can rebuild a laptop from scratch (or share the tooling) with a couple of commands.

## Repository layout
- `linux/mint/debian-setup.sh` — opinionated Mint/Debian setup script that installs Python, Node via NVM + Corepack, Go, Java via SDKMAN, and supporting CLI tools.
- `linux/mint/versions.conf` — single source of truth for the tool versions the installer should pull; update this file before re-running the bootstrapper.
- `nvim/init.lua` & `nvim/lua/mycfg/` — primary NeoVim config entry point and all supporting modules (settings, mappings, plugin specs, per-language bundles, feature toggles).
- `nvim/nvim/` — mirror of the final `~/.config/nvim` tree for copying to workstations without running the installer.
- `nvim/lazy-lock.json` — plugin lockfile maintained by Lazy; refresh it via `:Lazy sync` rather than manual edits.

## Bootstrap a Linux Mint machine
1. Clone the repo and review `linux/mint/versions.conf`; adjust pins if you need different runtimes.
2. From the repo root, run the installer so relative paths resolve correctly:
   ```bash
   bash linux/mint/debian-setup.sh
   ```
3. Let the script finish installing base packages, Python/pipx, Node (NVM + Corepack), Go, and Java (Temurin 21 via SDKMAN). It will also patch your `.bashrc` with PATH exports as needed.
4. Open a new shell (`exec bash -l`) to pick up the updated environment.

### Quick validation commands
- `bash -n linux/mint/debian-setup.sh` — syntax check the installer.
- `shellcheck linux/mint/debian-setup.sh` — lint for common shell pitfalls.
- `python3 --version`, `node -v`, `go version`, `java -version` — confirm the expected toolchain after the run.

## Current version pins
The installer reads these values from `linux/mint/versions.conf`; bump them there before re-running.

| Tool   | Version   |
| ------ | --------- |
| Python | 3.12      |
| Go     | 1.25.4    |
| Node   | 22.21.1   |
| Java   | 21-tem    |
| NeoVim | 0.12.0    |
| NVM    | 0.40.3   |

### Overriding version
Edit the versions.conf file and change the versions to match your needs. 

## Contributing & future tweaks
- Keep sensitive machine overrides out of git; `versions.conf` should stay public-safe.
- When changing version pins or the installer, call out the change and rerun the validation commands above.
- For NeoVim changes, ensure a clean `nvim --clean -u nvim/init.lua` start and a successful `nvim --headless "+Lazy sync" "+qa"` so plugin pins stay in sync.
- If you add packages or destructive steps (for example wiping `/usr/local/go`), document why it remains safe and keep the guard clauses that require sudo.
