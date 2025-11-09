# 🧠 AGENTS.md

> **Purpose:**  
> This document explains what each GitHub Action workflow does, why it exists, and how it fits into the repository’s automation system.  
> Think of it as the instruction manual for your repo’s robots.

---

## 🧩 Overview

This repository uses GitHub Actions workflows (*agents*) to automate setup verification, linting, and dependency maintenance.  
All workflows live under `.github/workflows/`.

Each workflow has a focused purpose:
- **Bootstrap validation** – tests `linux/mint/debian-setup.sh` for correctness and repeatability.  
- **Code quality** – enforces shell best practices with ShellCheck.  
- **Dependency management** – keeps `versions.conf` and your README versions aligned with upstream releases.

---

## ⚙️ Workflows

### 🧪 `debian-setup-test.yml`

**Purpose:**  
Validates that `linux/mint/debian-setup.sh` installs the correct tool versions and behaves idempotently.

**What it does:**
1. Loads desired versions from `linux/mint/versions.conf`.
2. Runs the setup script once to install dependencies.  
3. Verifies installed versions (Python, Go, Node, Neovim, NVM, Java) match `versions.conf`.
4. Runs the script again to ensure idempotency — no duplicate PATH lines, no reinstallation spam.
5. Fails if any mismatch or error occurs.

**Why it matters:**  
Guarantees your bootstrap script works from a clean state and doesn’t break when re-run.

---

### 🧹 `shell-lint.yml`

**Purpose:**  
Runs [ShellCheck](https://github.com/koalaman/shellcheck) across all `.sh` scripts to catch unsafe quoting, syntax issues, and bad practices.

**What it does:**
- Scans every shell script under `linux/mint/`.
- Follows sourced files via `-x` (using simple stub files in `ci-stubs/`).
- Reports only *errors*, ignoring low-impact warnings to reduce noise.

**Why it matters:**  
Keeps your install scripts predictable and cross-shell safe.

---

### 🤖 `renovate.json` (Renovate Bot)

**Purpose:**  
Automatically updates the version pins in `linux/mint/versions.conf` and keeps README tables or blocks synchronized.

**What it does:**
- Watches for new stable releases of Python, Go, Node, Neovim, NVM, etc.  
- Opens pull requests to bump those versions.  
- Optionally syncs the README’s version table to match.  
- Can be scheduled weekly (e.g. **“before 10am on Friday”**) to minimize noise.

**Why it matters:**  
Saves you from manually chasing upstream tool updates.

---

## 🧭 Repository Structure

| Path | Description |
|------|--------------|
| `linux/mint/debian-setup.sh` | Main Linux/Mint environment bootstrap script. |
| `linux/mint/versions.conf` | Single source of truth for pinned tool versions. |
| `.github/workflows/` | All CI/CD workflows live here. |
| `.github/AGENTS.md` | This document — explains each workflow. |
| `ci-stubs/` | Placeholder scripts for `nvm.sh`, `sdkman-init.sh`, etc. (used only for linting). |
| `README.md` | User-facing project overview, may display version info. |

---

## 🧩 Adding or Updating Workflows

1. **Keep scope narrow** — one responsibility per workflow.  
2. **Name clearly** — lowercase with hyphens, e.g. `python-lint.yml`.  
3. **Document here** — update this file’s “Workflows” section.  
4. **Scope triggers** — restrict `on.push.paths` to relevant files.  
5. **Prefer idempotency** — every workflow should be safe to rerun.

---

## 🧰 Local Testing

You can locally mimic what CI does before pushing:

```bash
# Run shell lint locally
shellcheck -x linux/mint/debian-setup.sh

# Dry-run setup script
bash linux/mint/debian-setup.sh
