#!/usr/bin/env bash
set -euo pipefail

cli_version="${M365_CLI_VERSION:-11.10.0}"
mcp_version="${M365_MCP_VERSION:-0.1.23}"

[[ "$(uname -s)" == "Darwin" ]] || { echo "ERROR: this installer is for macOS." >&2; exit 2; }

activate_lts_node() {
  local candidate
  if command -v node >/dev/null 2>&1; then
    case "$(node -p 'process.versions.node.split(`.`)[0]')" in 22|24) return 0 ;; esac
  fi
  for candidate in /opt/homebrew/opt/node@24/bin /usr/local/opt/node@24/bin /opt/homebrew/opt/node@22/bin /usr/local/opt/node@22/bin; do
    if [[ -x "$candidate/node" ]]; then export PATH="$candidate:$PATH"; return 0; fi
  done
  echo "ERROR: install an active LTS first: brew install node@24" >&2
  exit 3
}

activate_lts_node
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
