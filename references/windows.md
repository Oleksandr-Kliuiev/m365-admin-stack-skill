# Native Windows runbook

Use PowerShell 7 (`pwsh`) when available. Windows PowerShell 5.1 is not the target runtime for Graph tooling.

## Preflight

```powershell
$PSVersionTable
[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
Get-Command node,npm.cmd,codex,m365.cmd,npx.cmd,pwsh -ErrorAction SilentlyContinue
node --version
npm.cmd config get prefix
npm.cmd root -g
```

## Install the CLI and MCP adapter

From the skill directory:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
```

If the script installs Node LTS, close and reopen the terminal before rerunning it so the PATH refreshes. The script uses `npx.cmd`, not the Unix shim.

Merge [../assets/mcp-config-windows.toml](../assets/mcp-config-windows.toml) into `%USERPROFILE%\.codex\config.toml`, replacing `__NPX_CMD_PATH__` with `(Get-Command npx.cmd).Source` and `__MCP_VERSION__` with `0.1.23`. Escape backslashes for TOML or use forward slashes. Preserve unrelated Codex configuration. Fully restart Codex Desktop and open a new task.

## Optional Graph PowerShell

On Windows clients, the official recommended installation is WinGet:

```powershell
winget install --id Microsoft.PowerShell --source winget
pwsh -NoProfile -File .\scripts\install-graph-modules.ps1
```

For Windows Server, use the installation method supported for that server version. See the [official Windows installation page](https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-windows).

## Verify

```powershell
pwsh -NoProfile -File .\scripts\doctor-windows.ps1
pwsh -NoProfile -File .\scripts\doctor-windows.ps1 -Online
```

If Codex runs inside WSL, stop and use [linux.md](linux.md) instead. Installing the native Windows stack does not configure the WSL instance.
