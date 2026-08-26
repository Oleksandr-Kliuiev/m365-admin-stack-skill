# macOS runbook

Use this runbook for both Apple Silicon (`arm64`) and Intel (`x86_64`).

## Preflight

```bash
sw_vers
uname -m
command -v node npm codex m365 npx pwsh || true
node --version 2>/dev/null || true
npm config get prefix
npm root -g
```

Prefer Homebrew Node 24 LTS. Node 22 LTS is also accepted by this tested stack. Do not replace a working LTS merely because npm reports a transient network failure.

```bash
brew install node@24
export PATH="$(brew --prefix node@24)/bin:$PATH"
```

Persist the PATH line in the user's shell profile only after confirming which shell and Homebrew prefix are actually active.

## Install the CLI and MCP adapter

From the skill directory:

```bash
chmod +x scripts/*.sh
scripts/install-macos.sh
```

The script installs both PnP packages globally and adds `m365` through `codex mcp add` when absent. It preserves an existing MCP entry.

Inspect `~/.codex/config.toml`. For a portable direct server, merge [../assets/mcp-config-unix.toml](../assets/mcp-config-unix.toml), replacing `__NPX_PATH__` with `command -v npx` and `__MCP_VERSION__` with `0.1.23`. Never overwrite unrelated Codex settings. Fully quit and reopen Codex Desktop, then start a new task.

## Optional Graph PowerShell

Use Microsoft's current signed and notarized stable PKG matching `arm64` or `x64`; this avoids depending on whether a Homebrew cask happens to expose the stable channel. Follow the [official macOS installation page](https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-macos).

After `pwsh --version` succeeds:

```bash
pwsh -NoProfile -File scripts/install-graph-modules.ps1
```

## Verify

```bash
scripts/doctor-unix.sh
scripts/doctor-unix.sh --online
```

The online mode is read-only but requires an existing CLI login. Also verify MCP command discovery in a new Codex task; the shell doctor cannot prove that the Desktop process loaded the server.
