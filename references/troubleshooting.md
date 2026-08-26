# Troubleshooting map

Diagnose one layer at a time: network → Node/npm → global packages/catalog → CLI login → Graph → MCP process → Codex Desktop → optional Graph PowerShell.

## npm network errors

Symptoms: `ECONNRESET`, `ENOTFOUND`, timeouts, or TLS/proxy failures during bootstrap.

1. Do not assume Node is the cause. Record `node --version`, `npm --version`, `npm config get registry`, and proxy configuration.
2. Test DNS/TLS and `npm ping` from the user's real terminal. A sandboxed agent can have different network access.
3. Retry with the bounded retry/timeouts in [../assets/npmrc.template](../assets/npmrc.template).
4. If an enterprise proxy is required, configure the exact approved proxy/CA. Never disable TLS verification globally.
5. Use Node 22 or 24 LTS. An odd-numbered Current release is a separate compatibility risk, not an explanation for every reset.

For npm cache or prefix `EACCES`/`EPERM`, inspect ownership and paths first. Do not reflexively run all npm operations with `sudo`; prefer a user-owned version manager or prefix.

## MCP search says the CLI package or catalog is missing

Typical error:

```text
cli-microsoft365 npm package not found or allCommandsFull.json file not found
```

Repair the same global npm prefix used by the MCP process:

```bash
npm root -g
npm install --global @pnp/cli-microsoft365@11.10.0
test -f "$(npm root -g)/@pnp/cli-microsoft365/allCommandsFull.json"
```

On Windows use `npm.cmd root -g` and `Test-Path`. A local project install is insufficient for adapter `0.1.23` command discovery.

## MCP is enabled but `/mcp` shows nothing

Codex Desktop may not expose `/mcp` as a slash-command menu. Treat Settings → Plugins → MCP and an actual tool call as authoritative.

1. Confirm `m365` is enabled in settings.
2. Run `codex mcp get m365` in the same user environment.
3. Ensure the entry is in the global user config if it must work across projects.
4. Fully quit Codex, reopen it, and start a new task.
5. Ask for a read-only tool call; do not test by changing the tenant.

“Authentication is not supported” in the MCP settings is normal for this local stdio server. Authenticate with `m365 login`; the MCP adapter reuses that CLI context.

## Tools are missing or never selected

The names are snake_case, not camelCase:

```text
m365_search_commands
m365_get_command_docs
m365_get_best_practices
m365_run_command
```

Check `enabled_tools` and per-tool approvals in the config assets. `m365_run_command` must remain `prompt` because it can mutate tenant state.

Use this safe MCP sequence:

1. Search for the command that returns the signed-in user.
2. Fetch its documentation.
3. Show the exact read-only command and request confirmation if the adapter routes execution through `m365_run_command`.
4. Execute and report tenant/account; make no changes.

If direct Graph works but search/docs fail, repair the global catalog rather than changing Graph permissions.

## PowerShell prompt changes to `>>`

PowerShell is waiting for an unfinished quote, parenthesis, or backtick continuation. Press `Ctrl+C` and rerun the request on one line:

```powershell
Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/me?$select=id,displayName,userPrincipalName'
```

Do not paste Markdown link syntax into the URI. A successful CLI login does not authenticate Graph PowerShell; run `Connect-MgGraph` separately.

## Read-only smoke prompts for Codex

- “Using the m365 MCP server, search for the correct command and show its docs for returning my current signed-in user. Do not execute yet.”
- “Run only a read-only Microsoft Graph v1.0 `/me` check and return display name and UPN. Make no changes.”
- “List tenant domains read-only and state which is default. Do not create or update anything.”
- “List the first five users with only ID, display name, UPN, and account-enabled state. Do not modify users.”
- “List Microsoft 365 groups read-only with stable object IDs. Do not change membership.”

If a query needs broader consent, stop and report the exact missing permission instead of granting it.
