# Authentication and tenant setup

Package installation is local. Everything in this document crosses into the Microsoft 365 tenant and therefore requires the user's explicit approval and review of the resolved tenant.

## Before setup

Run read-only local checks and ask the user to confirm:

- tenant domain and tenant ID;
- interactive workstation versus unattended automation;
- whether an organization-approved Entra app already exists;
- the minimum workloads and Graph scopes required.

Do not create a second app registration merely because the existing Client ID is not immediately visible. Do not add broad scopes “for later.”

## `m365 setup` wizard choices

- **Create a new app registration**: choose only when no approved existing app is available and the user explicitly approves creating one. Review delegated permissions before consent.
- **Use an existing app registration**: choose when the organization supplies its Client ID, tenant, redirect/platform configuration, and approved scopes.
- **Skip configuring app registration**: choose only when configuration will intentionally be completed later. The MCP adapter cannot compensate for a missing CLI identity.
- **Interactively**: choose for Codex Desktop and administrator-driven terminal work.
- **Scripting**: choose only for a planned automation identity and authentication design.
- **Beginner/Proficient**: affects guidance and defaults, not privileges. Choose Beginner when unsure.

Setup configures an identity; it does not prove the user is signed in. Login and doctor checks are still required afterward.

## Interactive login

Browser login on a workstation:

```bash
m365 login --authType browser
```

Device code on a headless or remote system:

```bash
m365 login --authType deviceCode
```

Use `m365 status`, `m365 connection list`, and `m365 connection use` to make the active identity explicit. Log out with `m365 logout` before decommissioning or handing over a machine.

The session is not a simple fixed-duration browser cookie. The CLI caches connection material and can refresh access tokens until sign-in frequency, Conditional Access, revocation, password/security changes, app policy, or logout forces reauthentication. Never promise a universal lifetime; test the tenant's policy.

## Microsoft Graph PowerShell is separate

Installing Graph modules does not reuse the CLI connection. Start with the minimum delegated scope:

```powershell
Connect-MgGraph -Scopes "User.Read" -NoWelcome
Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/me?$select=id,displayName,userPrincipalName'
Get-MgContext
Disconnect-MgGraph
```

Request scopes such as `User.Read.All`, `Group.Read.All`, or directory permissions only for a concrete task. Some require admin consent. Graph PowerShell maintains its own context and cache.

## Automation

Prefer certificate, managed identity, supported workload identity, or federated identity. Avoid client secrets; never use username/password authentication. Store private material in an OS or enterprise secret store, not the repository, shell history, command arguments, or Skill.

App IDs and tenant IDs are identifiers, not credentials, but avoid publishing them unnecessarily. Tokens, secrets, certificate passwords, and private keys are secrets.
