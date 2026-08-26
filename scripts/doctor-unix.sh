#!/usr/bin/env bash
set -uo pipefail

online=false
[[ "${1:-}" == "--online" ]] && online=true
failures=0

ok() { printf 'OK   %s\n' "$*"; }
info() { printf 'INFO %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*"; failures=$((failures + 1)); }

info "platform: $(uname -s) $(uname -m)"

for command_name in node npm codex m365 npx; do
  if command -v "$command_name" >/dev/null 2>&1; then
    ok "$command_name: $(command -v "$command_name")"
  else
    fail "$command_name is not on PATH"
  fi
done

if command -v node >/dev/null 2>&1; then
  node_major="$(node -p 'process.versions.node.split(`.`)[0]' 2>/dev/null || true)"
  if [[ "$node_major" == "22" || "$node_major" == "24" ]]; then
    ok "Node LTS: $(node --version)"
  else
    fail "Node $(node --version) is not accepted; use major 22 or 24"
  fi
fi

if command -v npm >/dev/null 2>&1; then
  npm_root="$(npm root -g 2>/dev/null || true)"
  if [[ -f "$npm_root/@pnp/cli-microsoft365/allCommandsFull.json" ]]; then
    ok "global M365 command catalog: $npm_root/@pnp/cli-microsoft365/allCommandsFull.json"
  else
    fail "global M365 command catalog is missing under npm root -g"
  fi
  [[ -d "$npm_root/@pnp/cli-microsoft365-mcp-server" ]] \
    && ok "global M365 MCP adapter installed" \
    || fail "global M365 MCP adapter is missing"
fi

if command -v m365 >/dev/null 2>&1; then
  ok "m365: $(m365 version 2>/dev/null || m365 --version 2>/dev/null || true)"
  info "Microsoft 365 login status:"
  m365 status 2>&1 || fail "m365 status failed"
fi

if command -v codex >/dev/null 2>&1; then
  if codex mcp get m365 >/dev/null 2>&1; then
    ok "global Codex MCP server 'm365' is configured"
  else
    fail "Codex MCP server 'm365' is not configured"
  fi
fi

if command -v pwsh >/dev/null 2>&1; then
  ok "PowerShell: $(pwsh --version)"
  pwsh -NoProfile -Command \
    "Get-InstalledModule -Name 'Microsoft.Graph.*' -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object Name,Version" \
    2>/dev/null || info "Graph module inventory was unavailable"
else
  info "optional PowerShell 7 is not installed"
fi

if $online; then
  info "running read-only Graph /me smoke test through CLI for Microsoft 365"
  m365 request --method get --url '@graph/me?$select=id,displayName,userPrincipalName' --output json \
    || fail "Graph /me smoke test failed"
else
  info "online smoke test skipped; pass --online after login to run it"
fi

if (( failures > 0 )); then
  printf 'RESULT %d core check(s) failed\n' "$failures"
  exit 1
fi
ok "local stack checks passed"
