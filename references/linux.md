# Linux and WSL runbook

Use the Linux path inside WSL. Do not mix Windows and WSL npm prefixes, Codex configs, PowerShell modules, or authentication caches.

## Preflight

```bash
uname -a
uname -m
cat /etc/os-release
command -v node npm codex m365 npx pwsh || true
node --version 2>/dev/null || true
npm config get prefix
npm root -g
```

Install Node 24 or 22 LTS using the organization-approved version manager or the distribution/vendor's current official instructions. Detect the distribution before choosing `apt`, `dnf`, `yum`, `zypper`, `apk`, or another manager. Do not blindly execute an unreviewed remote shell script.

Ensure the current user owns the selected npm prefix. Prefer a user-scoped version manager over `sudo npm install -g` on shared hosts.

## Install the CLI and MCP adapter

```bash
chmod +x scripts/*.sh
scripts/install-linux.sh
```

For Codex running in the same Linux environment, merge [../assets/mcp-config-unix.toml](../assets/mcp-config-unix.toml) into `~/.codex/config.toml`, replacing the placeholders. Never overwrite unrelated settings. Restart the Codex process after changing it.

## Authentication choice

- Desktop Linux with a usable browser: delegated browser authentication is preferred.
- SSH, server, container, or WSL without reliable browser handoff: use device code.
- CI/CD: use certificate, managed identity, workload identity, or supported federated identity. Do not reuse an interactive cache.

Read [authentication.md](authentication.md) before setup or login.

## Optional Graph PowerShell

Detect the exact distribution and release, then use Microsoft's current repository/package instructions. The supported list and per-distribution links are on the [official Linux overview](https://learn.microsoft.com/powershell/scripting/install/linux-overview). Prefer LTS distributions and stable PowerShell.

```bash
pwsh -NoProfile -File scripts/install-graph-modules.ps1
```

## Verify

```bash
scripts/doctor-unix.sh
scripts/doctor-unix.sh --online
```

On multi-user or shared systems, review permissions on CLI configuration and connection files without printing their contents. Token caches must never be copied into the repository or to another machine.
