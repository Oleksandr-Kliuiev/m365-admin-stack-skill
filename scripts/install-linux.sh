#!/usr/bin/env bash
set -euo pipefail

cli_version="${M365_CLI_VERSION:-11.10.0}"
mcp_version="${M365_MCP_VERSION:-0.1.23}"

[[ "$(uname -s)" == "Linux" ]] || { echo "ERROR: this installer is for Linux or WSL." >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo "ERROR: install Node.js 22 or 24 LTS first." >&2; exit 3; }
node_major="$(node -p 'process.versions.node.split(`.`)[0]')"
[[ "$node_major" == "22" || "$node_major" == "24" ]] || {
  echo "ERROR: Node $(node --version) is not an accepted LTS major (22 or 24)." >&2
  exit 3
}
command -v npm >/dev/null 2>&1 || { echo "ERROR: npm is missing." >&2; exit 3; }

echo "Using Node $(node --version) and npm $(npm --version) from $(command -v node)"
npm install --global \
  "@pnp/cli-microsoft365@$cli_version" \
  "@pnp/cli-microsoft365-mcp-server@$mcp_version" \
  --no-audit --no-fund --fetch-retries=5 --fetch-timeout=120000

m365 cli config set --key prompt --value false
m365 cli config set --key output --value text
m365 cli config set --key helpMode --value full

if command -v codex >/dev/null 2>&1; then
  if ! codex mcp get m365 >/dev/null 2>&1; then
    npx_path="$(command -v npx)"
    codex mcp add m365 -- "$npx_path" -y "@pnp/cli-microsoft365-mcp-server@$mcp_version"
  else
    echo "Codex MCP server 'm365' already exists; preserving its configuration."
  fi
else
  echo "WARN: Codex CLI is not on PATH; add the MCP server after Codex is installed."
fi

echo "Local packages are ready. Tenant setup/login was intentionally not run."
echo "Next: review references/authentication.md, then run scripts/doctor-unix.sh."
