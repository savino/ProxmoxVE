# GitHub Copilot / AI Agent Instructions for ProxmoxVE 🔧

## Purpose
Short, actionable notes to help an AI coding agent be productive immediately in this repository.

## Quick orientation ✅
- This repo is a collection of Proxmox helper scripts (bash) grouped by purpose: `ct/` (container scripts), `install/` (install helpers), `tools/` (addons), and `misc/` (core libs).
- Primary libraries: `misc/build.func`, `misc/tools.func`, `misc/install.func`, and `misc/core.func`. Read `docs/misc/*` for detailed flowcharts and function references.

## Essential commands (examples) 💡
- Run a container install locally: `bash ct/<app>.sh` (e.g., `bash ct/home-assistant.sh`).
- Fast dev/test: `VERBOSE=yes dev_mode="dryrun,logs" bash ct/<app>.sh`
- Keep troubleshooting container: `export dev_mode="motd,keep,breakpoint,logs" && bash ct/<app>.sh`
- Setup fork & environment: `bash docs/contribution/setup-fork.sh --full`

## Naming & structure patterns 📁
- Container scripts: `ct/<app>.sh` (use `/ct/example.sh` as template).
- Install scripts: `install/<app>-install.sh` (called by `ct/` scripts).
- Defaults: `/usr/local/community-scripts/default.vars` and app defaults located at `/usr/local/community-scripts/defaults/<app>.vars` — helper: `get_app_defaults_path()`.
- Use `var_*` variables for configuration, and `load_vars_file()` to safely parse `.vars` files (no `eval` or `source`).

## Key conventions & helpers 🧩
- All scripts: `#!/usr/bin/env bash` shebang and follow coding standards in `docs/contribution/`.
- Use messaging helpers: `msg_info`, `msg_ok`, `msg_error` (found in core libs).
- For package installs and environment setup prefer `tools.func` (Debian) or `alpine-tools.func` (Alpine).
- For Docker setup in install scripts, prefer `setup_docker` from `tools.func` over ad-hoc install logic when compatible.
- Many scripts source the central helpers remotely during CI: `source <(curl -fsSL https://raw.githubusercontent.com/savino/ProxmoxVE/main/misc/tools.func)` — changes to `tools.func` affect a large surface.

## Dev & debug workflow (explicit) 🐞
- Use `dev_mode` env var (see `docs/DEV_MODE.md`) to combine: `dryrun`, `trace`, `pause`, `motd`, `keep`, `breakpoint`, `logs`.
- For fork testing, always run `bash docs/contribution/setup-fork.sh --full` first so internal curl URLs point to your fork (not upstream).
- Test from your fork raw URL (`bash -c "$(curl -fsSL https://raw.githubusercontent.com/<user>/ProxmoxVE/main/ct/<app>.sh)"`), not just local file execution.
- If setup-fork rewrite is skipped, `build.func` may still fetch install scripts from upstream and fail with 404 for new fork-only scripts.
- Typical sequence for testing a new/changed script:
  1. `export VERBOSE=yes`
  2. `export dev_mode="dryrun,logs"` (inspect what would run)
  3. `export dev_mode="trace,pause,logs"` (step through with traces)
  4. If failure, run `dev_mode="motd,keep,breakpoint,logs"` to inspect container interactively.

## Troubleshooting notes 🔍
- Install scripts are expected to run through CT flow (`start -> build_container`). Direct manual invocation can miss required environment values.
- If manual install execution is unavoidable, export at least `APP`, `APPLICATION`, and `NSAPP` before running the install script to avoid late-stage unbound variable failures in finalization helpers.
- If CT console asks for login unexpectedly, verify install finalization completed (`motd_ssh`, `customize`, `cleanup_lxc`). A late script error can leave shell/login customizations incomplete.
- `ProxmoxVE-Local` is useful for local iteration, but keep fork URL testing as the canonical validation path for PR readiness.

## Runtime validation checklist ✅
- When install output says "completed" but app is unreachable, validate runtime before changing scripts:
  1. `systemctl status docker --no-pager`
  2. `docker ps -a`
  3. `docker logs --tail 200 <container_name>`
  4. `ss -lntp | grep <port>`
  5. `curl -I http://127.0.0.1:<port>` (inside CT)
- For services running as UID/GID 1000 in Docker, verify persistent data directory ownership/permissions match expected UID/GID before concluding installation succeeded.
- Do not treat container creation success as application success: ensure app health/listening checks pass before final confirmation.

## CI / contribution notes ⚙️
- PR validation uses workflow helper scripts under `.github/workflows/scripts/app-test/` which mirror in-repo behavior. See these when modifying build/test logic.
- Keep changes backwards compatible: many users run scripts directly via `curl | bash` in the wild.

## Where to look first (read this before coding) 📚
- `docs/contribution/README.md` — contributor flow and templates
- `docs/DEV_MODE.md` — concrete test & debug modes
- `docs/TECHNICAL_REFERENCE.md` — variable precedence & config system
- `docs/misc/tools.func/TOOLS_FUNC_FUNCTIONS_REFERENCE.md` — canonical helpers

## Actionable tips for making edits ✍️
- When adding a new `ct/<app>.sh`:
  - Copy `ct/example.sh` or follow `docs/contribution/templates_ct/`.
  - Add unit-like manual test steps to the script header (how to call with dev_mode/verbose).
  - Ensure `load_vars_file` usage for defaults and no `eval`.
- When touching `tools.func` or build logic: add integration notes and consider effects for both Debian and Alpine flows.

## Example AI tasks & prompts (use these) 🤖
- "Add support for X in `ct/<app>.sh` and include test snippet: how to run `VERBOSE=yes dev_mode=trace,pause` and what output to assert on." 
- "Refactor `tools.func` helper Y to accept an extra param and update two callers: list files and add tests using `dev_mode=dryrun,logs`."

---
If anything is unclear or you want more examples from specific files (e.g., `ct/homarr.sh` or `misc/tools.func`), tell me which file and I will expand the instructions or add inline examples. ✅
