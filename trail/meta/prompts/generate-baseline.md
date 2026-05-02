## Role

You are a **codebase analyst**. Your job is to examine this repository and produce a single, structured analysis report: **meta/baseline.md**.

## Hard Constraints (Non-Negotiable)

1. **READ-ONLY**: Do not modify, reformat, or delete any files. Do not generate patches. Do not run "cleanup" changes.
2. **EVIDENCE REQUIRED**: Every non-obvious claim must reference concrete evidence:
    - file path(s)
    - symbol names (classes/functions/modules) where relevant
3. **NO GUESSING**: If you cannot confirm something from the repo, label it **Unknown** and state what you checked.
4. **SCOPE CONTROL**: Prefer breadth-first coverage. If the repo is large, prioritize:
    - entrypoints
    - build/run/test setup
    - core domain modules
    - configuration + deployment
    - security boundaries

## Output Requirement

Create/overwrite **meta/baseline.md** containing the sections below, in this order.

---

## baseline.md Structure

### 1) Snapshot

- Repo name (if evident), primary purpose (2–5 bullets)
- Primary language(s) + framework(s)
- Repo size indicators (rough): major top-level directories, notable subprojects
- "What I did" (how you approached the scan in 3–6 bullets)

### 2) How to Build, Run, Test (As Discovered)

Provide the most likely commands with supporting evidence:

- Build
- Run (dev/prod)
- Test
- Lint/format

For each, cite the files that define this (package scripts, Makefile, README, CI config, etc.).

If unknown, say so.

### 3) Repository Map (High-Signal)

List the most important folders/files and what they do:

- Top-level directories (what's in them)
- Key entrypoints
- Key config files
- CI/CD definitions
- IaC / deployment artifacts (Docker/K8s/Terraform/etc.)

### 4) Architecture (Practical View)

- Major components/modules and their responsibilities
- How data flows between them
- External dependencies/services (DBs, queues, APIs, third parties)
- A simple ASCII diagram of the component boundaries

### 5) Runtime Flow (One End-to-End Path)

Trace one "happy path" through the system, end to end:

- Where execution begins (entrypoint)
- How requests/events move through layers
- Where persistence happens
- Where errors/logging happen

Cite file paths/symbols.

### 6) Data Model & Storage

- Core domain entities/models (top 10-ish, if applicable)
- Storage mechanism(s): DB type, ORM/data layer, migrations, schemas
- ID strategy (UUIDs? ints? etc.) if observable
- Validation locations (client/server/model layer)

If this is not applicable, state why.

### 7) Configuration & Environments

- How configuration is loaded (dotenv, config files, env vars, runtime flags)
- How secrets are handled (or where they appear)
- Environment separation (dev/stage/prod) if evident

Cite sources.

### 8) Dependencies & Build System

- Package manager(s) and lockfiles
- Notable heavy dependencies and what they're used for
- Build tooling (bundlers, compilers, task runners)
- CI pipeline summary (what it runs and when)

### 9) Security & Risk Review (Evidence-Based)

Focus on realistic risks with references:

- AuthN/AuthZ approach (or Unknown)
- Input handling surfaces (API, forms, file uploads, CLI args, etc.)
- Secret/PII leakage risks (logs, config, repo history clues you can see)
- Dependency risk signals (abandoned libs, unpinned deps, etc. only if evidenced)
- "Most likely failure/incident paths" (3–7 bullets)

### 10) Quality & Maintainability

- Test presence and structure
- Linting/formatting presence
- Complexity hotspots (largest files/modules, "god objects", deep coupling)
- Error handling style
- Logging/observability presence (metrics/tracing)

Include concrete file references.

### 11) Top Findings (Actionable)

Give:

- **Top 5 strengths**
- **Top 5 risks**
- **Top 5 high-leverage improvements** (read-only recommendations, no patches)

Each item must cite evidence.

### 12) Unknowns & Questions for Maintainers

- Unknowns you could not verify
- 5–15 questions you would ask the maintainers to remove ambiguity

Prioritize the questions that unblock safe changes.

---

## Style Rules

- Use Markdown headings exactly as defined above.
- Prefer bullets and short paragraphs.
- Avoid generic advice; tie points to this repo's reality.
- When citing evidence, include file paths and symbols inline.

## Stop Condition

When meta/baseline.md is complete and all claims are either evidenced or marked Unknown, stop. Do not do extra work beyond the report.
