# Security Policy

## Reporting a Vulnerability

Time Squirrel is a local-first macOS app — it has no server, no accounts, and no network communication. The attack surface is limited to the app binary and the local files it reads and writes.

If you believe you have found a security vulnerability, please report it privately rather than opening a public issue.

**Use GitHub's private vulnerability reporting:**
[Report a vulnerability](https://github.com/Ventura-Nomadica/time-squirrel/security/advisories/new)

Please include:
- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof of concept
- The macOS version and Time Squirrel version affected

## What to expect

- Acknowledgement within 5 business days
- A fix or mitigation plan within 30 days for confirmed vulnerabilities
- Credit in the release notes if you would like it

## Scope

In scope:
- Code execution via crafted session files
- Privilege escalation
- Data exfiltration from the local session store

Out of scope:
- Denial of service via resource exhaustion
- Issues requiring physical access to the machine
- Social engineering

## Supported versions

Only the latest release is actively maintained.
