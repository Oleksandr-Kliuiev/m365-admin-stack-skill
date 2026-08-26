[CmdletBinding()]
param([switch]$Online)

$ErrorActionPreference = "Continue"
if (-not $IsWindows) { throw "This doctor is for native Windows. Use doctor-unix.sh on this host." }
$failures = 0

function Write-Ok([string]$Message) { Write-Host "OK   $Message" }
function Write-Info([string]$Message) { Write-Host "INFO $Message" }
function Write-Fail([string]$Message) { Write-Host "FAIL $Message"; $script:failures++ }

Write-Info "platform: Windows $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
foreach ($name in @("node", "npm.cmd", "codex", "m365.cmd", "npx.cmd")) {
    $resolved = Get-Command $name -ErrorAction SilentlyContinue
    if ($resolved) { Write-Ok "$name`: $($resolved.Source)" } else { Write-Fail "$name is not on PATH" }
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    $major = [int](& node -p "process.versions.node.split('.')[0]")
    if ($major -in @(22, 24)) { Write-Ok "Node LTS: $(& node --version)" }
    else { Write-Fail "Node $(& node --version) is not accepted; use major 22 or 24" }
}

if (Get-Command npm.cmd -ErrorAction SilentlyContinue) {
    $npmRoot = (& npm.cmd root -g).Trim()
    $catalog = Join-Path $npmRoot "@pnp/cli-microsoft365/allCommandsFull.json"
    if (Test-Path $catalog) { Write-Ok "global M365 command catalog: $catalog" }
    else { Write-Fail "global M365 command catalog is missing under npm root -g" }
    $adapter = Join-Path $npmRoot "@pnp/cli-microsoft365-mcp-server"
    if (Test-Path $adapter) { Write-Ok "global M365 MCP adapter installed" }
    else { Write-Fail "global M365 MCP adapter is missing" }
}

if (Get-Command m365.cmd -ErrorAction SilentlyContinue) {
    Write-Ok "m365: $(& m365.cmd version)"
    Write-Info "Microsoft 365 login status:"
    & m365.cmd status
    if ($LASTEXITCODE -ne 0) { Write-Fail "m365 status failed" }
}

if (Get-Command codex -ErrorAction SilentlyContinue) {
    & codex mcp get m365 *> $null
    if ($LASTEXITCODE -eq 0) { Write-Ok "global Codex MCP server 'm365' is configured" }
    else { Write-Fail "Codex MCP server 'm365' is not configured" }
}

if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    Write-Ok "PowerShell: $(& pwsh --version)"
    & pwsh -NoProfile -Command "Get-InstalledModule -Name 'Microsoft.Graph.*' -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object Name,Version"
}
else { Write-Info "optional PowerShell 7 is not installed" }

if ($Online) {
    Write-Info "running read-only Graph /me smoke test through CLI for Microsoft 365"
    & m365.cmd request --method get --url '@graph/me?$select=id,displayName,userPrincipalName' --output json
    if ($LASTEXITCODE -ne 0) { Write-Fail "Graph /me smoke test failed" }
}
else { Write-Info "online smoke test skipped; pass -Online after login to run it" }

if ($failures -gt 0) { Write-Host "RESULT $failures core check(s) failed"; exit 1 }
Write-Ok "local stack checks passed"
