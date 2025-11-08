# Repository Guidelines

## Project Structure & Module Organization
Automation lives under `linux/`; `linux/mint/debian-setup.sh` reads version pins from `linux/mint/versions.conf`. NeoVim loads from `nvim/init.lua`, which wires modules inside `nvim/lua/mycfg/` (settings, mappings, plugin specs, and per-language bundles). `nvim/nvim/` mirrors the final `~/.config/nvim` tree for quick copying to a workstation, and plugin pins reside in `nvim/lazy-lock.json`.

## Build, Test, and Development Commands
- `bash linux/mint/debian-setup.sh` — installs the pinned desktop toolchain; run from the repo root for correct relative paths.
- `nvim --headless "+Lazy sync" "+qa"` — syncs plugins according to `lazy-lock.json` without opening the UI.
- `nvim --clean -u nvim/init.lua` — launches NeoVim with only this config, ideal while editing Lua modules.

## Coding Style & Naming Conventions
Shell work targets Bash, begins with `#!/usr/bin/env bash`, enables `set -euo pipefail`, and sticks to two-space indentation. Favor snake_case helper names and `printf`/`read` so the script remains POSIX-friendly. Lua modules belong under `nvim/lua/mycfg/`, use two spaces, snake_case filenames that match their `require("mycfg.<name>")` path, and keep plugin specs grouped by concern (core vs `dev/<lang>`); refresh `nvim/lazy-lock.json` via Lazy instead of hand edits.

## Testing Guidelines
Run `bash -n linux/mint/debian-setup.sh` and `shellcheck linux/mint/debian-setup.sh` before opening a PR, and share the output whenever privileged code changes. NeoVim updates must start cleanly with `nvim --clean -u nvim/init.lua` and allow `nvim --headless "+Lazy sync" "+qa"` to finish; wire new plugin toggles through `mycfg/devselect.lua` so reviewers can reproduce them.

## Commit & Pull Request Guidelines
Recent commits use short present-tense subjects (“Adding in debian setup”); follow that format and keep the body focused on rationale plus user impact. Every PR should list the commands/OS you used for validation and flag changes to `versions.conf` or lockfiles so reviewers rebuild appropriately. Link issues when relevant and attach screenshots only when UI-visible behavior changes.

## Security & Configuration Tips
Keep secrets and machine-local overrides out of git; `versions.conf` is for public pins only. When bumping versions or touching destructive steps (like wiping `/usr/local/go`), explain why the change is safe and retain the existing guard clauses around `sudo` operations.
