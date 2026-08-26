[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "PowerShell 7 or newer is required. Run this script in pwsh, not Windows PowerShell 5.1."
}

$modules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Identity.DirectoryManagement"
)

foreach ($module in $modules) {
    Install-Module -Name $module -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
}

Get-InstalledModule -Name "Microsoft.Graph.*" -ErrorAction SilentlyContinue |
    Where-Object Name -In $modules |
    Sort-Object Name |
    Select-Object Name, Version

Write-Host "Modules are installed. Authentication was intentionally not started."
Write-Host 'For a minimal test: Connect-MgGraph -Scopes "User.Read" -NoWelcome'
