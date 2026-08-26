[CmdletBinding()]
param(
    [string]$CliVersion = "11.10.0",
    [string]$McpVersion = "0.1.23"
)

$ErrorActionPreference = "Stop"
if (-not $IsWindows) { throw "This installer is for native Windows. Use install-macos.sh or install-linux.sh on this host." }

function Get-NodeMajor {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $null }
    return [int](& node -p "process.versions.node.split('.')[0]")
}

$nodeMajor = Get-NodeMajor
if ($nodeMajor -notin @(22, 24)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Install Node.js 22 or 24 LTS, reopen PowerShell, and rerun this script."
    }
    Write-Host "Installing the available Node.js LTS with winget..."
    & winget install --id OpenJS.NodeJS.LTS --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget failed to install Node.js LTS." }
    Write-Host "Node was installed. Close and reopen PowerShell, then rerun this script."
    exit 10
}

if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) { throw "npm.cmd is not on PATH." }
Write-Host "Using Node $(& node --version) and npm $(& npm.cmd --version) from $((Get-Command node).Source)"

& npm.cmd install --global "@pnp/cli-microsoft365@$CliVersion" "@pnp/cli-microsoft365-mcp-server@$McpVersion" `
    --no-audit --no-fund --fetch-retries=5 --fetch-timeout=120000
if ($LASTEXITCODE -ne 0) { throw "npm package installation failed." }

& m365.cmd cli config set --key prompt --value false
& m365.cmd cli config set --key output --value text
& m365.cmd cli config set --key helpMode --value full

if (Get-Command codex -ErrorAction SilentlyContinue) {
    & codex mcp get m365 *> $null
    if ($LASTEXITCODE -ne 0) {
        $npxPath = (Get-Command npx.cmd).Source
        & codex mcp add m365 -- $npxPath -y "@pnp/cli-microsoft365-mcp-server@$McpVersion"
        if ($LASTEXITCODE -ne 0) { throw "Failed to add the Codex MCP server." }
    }
    else {
        Write-Host "Codex MCP server 'm365' already exists; preserving its configuration."
    }
}
else {
    Write-Warning "Codex CLI is not on PATH; add the MCP server after Codex is installed."
}

Write-Host "Local packages are ready. Tenant setup/login was intentionally not run."
Write-Host "Next: review references/authentication.md, then run scripts/doctor-windows.ps1."
