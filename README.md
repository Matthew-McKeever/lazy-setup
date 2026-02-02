# lazy-setup

`lazy-setup` is my reproducible workstation kit: a Linux Mint bootstrapper that installs pinned language runtimes plus a curated NeoVim setup wired through Lazy.nvim. Everything lives in this repo so I can rebuild a laptop from scratch (or share the tooling) with a couple of commands.

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
- `node -v`, `go version`, `java -version` — confirm the expected toolchain after the run.

## Current version pins
The installer reads these values from `linux/mint/versions.conf`; bump them there before re-running.

| Tool   | Version   |
| ------ | --------- |
| Go     | 1.25.4    |
| Node   | 24.11.0   |
| Java   | 21-tem    |
| NeoVim | 0.11.5    |
| NVM    | 0.40.4    |

## Contributing & future tweaks
- Keep sensitive machine overrides out of git; `versions.conf` should stay public-safe.
- When changing version pins or the installer, call out the change and rerun the validation commands above.
- For NeoVim changes, ensure a clean `nvim --clean -u nvim/init.lua` start and a successful `nvim --headless "+Lazy sync" "+qa"` so plugin pins stay in sync.
- If you add packages or destructive steps (for example wiping `/usr/local/go`), document why it remains safe and keep the guard clauses that require sudo.
