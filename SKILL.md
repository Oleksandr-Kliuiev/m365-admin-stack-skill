---
name: m365-admin-stack
description: Install, repair, configure, and verify a Codex administration stack built from CLI for Microsoft 365, the official PnP MCP adapter, Microsoft Graph REST, and optional Microsoft Graph PowerShell. Use for macOS, Linux, WSL, and Windows setup or troubleshooting. Do not use for ordinary tenant administration after the stack is already healthy.
---

# M365 Admin Stack

Build a portable administration workstation without silently changing the tenant.

## Route by platform

1. Detect the operating system, architecture, shell, package manager, Node/npm, Codex, and PowerShell before installing anything.
2. Read only the matching guide:
   - macOS: [references/macos.md](references/macos.md)
   - Linux or WSL: [references/linux.md](references/linux.md)
   - Native Windows: [references/windows.md](references/windows.md)
3. Read [references/authentication.md](references/authentication.md) before tenant setup or login.
4. Read [references/troubleshooting.md](references/troubleshooting.md) only when a check fails.
5. Run the platform doctor and report the exact passing and failing layers.

## Preserve these compatibility invariants

- Use an active Node.js LTS major: 22 or 24. Reject odd-numbered Current releases and end-of-life releases even if a package declares a lower minimum.
- Install `@pnp/cli-microsoft365` globally. MCP command search depends on the CLI package catalog under `npm root -g`; a local-only install can leave Graph execution working while `m365_search_commands` fails with `allCommandsFull.json file not found`.
- Default to the tested pair CLI `11.10.0` and MCP adapter `0.1.23`. Upgrade only after checking official release notes and repeating all smoke tests.
- Add the MCP server to the global Codex configuration for Codex Desktop. A project-only entry may not appear in unrelated Desktop tasks.
- Use the actual snake_case tools: `m365_search_commands`, `m365_get_command_docs`, `m365_get_best_practices`, and `m365_run_command`.
- Require confirmation for every `m365_run_command` call. The other tools may be approved only after verifying they remain read-only.
- Treat “Authentication is not supported” on a local stdio MCP server as informational. The adapter reuses the CLI for Microsoft 365 login; it does not authenticate through the Codex MCP settings screen.
- Treat CLI for Microsoft 365 and Microsoft Graph PowerShell as separate clients with separate token caches and login commands.

## Tenant safety boundary

Installing packages and editing local Codex configuration does not authorize tenant setup, app registration, consent, new scopes, or tenant mutations.

- Stop for explicit approval before running `m365 setup`, granting consent, creating an Entra app, adding Graph scopes, or changing tenant data.
- Prefer delegated browser login on a desktop and device-code login on a headless host.
- Prefer certificate or workload identity for unattended automation. Never use username/password authentication.
- Never print, copy between machines, or commit tokens, refresh-token caches, client secrets, passwords, or private keys.
- For administration, discover read-only first, resolve stable IDs, preview the intended change, obtain explicit approval, mutate, then verify separately.

## Definition of done

Do not call the stack healthy until all requested layers pass:

1. Node/npm are active LTS and resolve from the expected path.
2. The global CLI package and its command catalog exist.
3. The MCP adapter is installed and the global Codex server is enabled.
4. `m365 status` shows the intended tenant and account.
5. A read-only Graph `/me` request succeeds.
6. Codex can list the four MCP tools and command search/docs return results.
7. If requested, PowerShell 7 and the selected Microsoft.Graph modules are installed; `Connect-MgGraph` and a separate read-only `/me` request succeed.

Do not declare success merely because package installation completed.
