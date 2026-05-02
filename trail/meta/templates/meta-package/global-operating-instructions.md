# Trail Global Operating Instructions

These instructions apply to **all executors** (human or AI) operating in any
role in this repository unless explicitly overridden by intent-level or
run-level operating instructions.

These rules are non-negotiable.

---

## Authority & Precedence

Instructions are composed in this order, from lowest to highest specificity:

1. `trail/meta/global-operating-instructions.md` (this file)
2. `trail/intents/<intent>/operating-instructions-override.md`
3. `trail/runs/<intent>/<run>/operating-instructions.md` (composite)

The more specific scope always wins. If instructions conflict, the higher-
specificity file governs. The run-level `operating-instructions.md` is fully
composed — executors read only that file and do not need to consult meta or
intent-level files directly.

---

## Roles

Trail has four roles. Role separation is enforced at all times.

- **Architect / Product Owner** — Human only. Defines and owns scope.
- **Manager** — Human or AI. Translates intent into executable run artifacts.
- **Developer** — Human or AI. Executes run artifacts and produces output.
- **Reviewer** — Human only. Verifies output against intent and run artifacts.

The Architect/Product Owner and Reviewer may be the same person.
No other role merging is permitted.

---

## Role Separation

- If acting as Manager: produce run artifacts. Do not write deliverables.
- If acting as Developer: execute run artifacts. Do not change scope or planning artifacts.
- If acting as Reviewer: verify outputs. Do not implement fixes.

Never merge roles implicitly.

---

## Scope Discipline

- Do only what you are explicitly instructed to do.
- Do not invent scope, features, files, platforms, or services.
- Do not refactor, optimize, or "clean up" unless explicitly required.
- Silence is not permission.

---

## File Access Boundaries

Executors must only access inputs that are explicitly declared in the intent
package or run artifacts. Undeclared inputs do not exist — regardless of
whether the executor is aware of them.

Declared inputs may live anywhere: the Trail folder structure, a file share,
a network drive, a cloud storage location, or any other accessible system.
Location does not matter. Declaration does.

If an input lives outside the Trail folder structure, it must be declared in
`intent.md` under Dependencies & Files with sufficient information for the
executor to locate it.

Default lookup order for inputs inside the Trail folder structure:
1. `trail/intents/<this-intent>/files/`
2. `trail/meta/files/`

### Developer file access

If you are acting as **Developer**, your permitted inputs are:

- Run artifacts in the current run folder (`operating-instructions.md`, `tasks.md`, `dev-prompt.md`)
- Input files explicitly listed in those artifacts (`trail/intents/<intent>/files/` and `trail/meta/files/`)

You must **not** read `intent.md`, `trail.md`, `global-operating-instructions.md`,
`operating-instructions-override.md`, `manager-instructions.md`, or any other
policy or scope file in `trail/intents/` or `trail/meta/`. These are Manager
inputs. The Manager is responsible for distilling all context you need into the
run artifacts. If something you need is missing from the run artifacts, stop and
document it in `results.md`.

---

## Assumptions & Ambiguity

- Do not ask questions. Questions move work into chat — chat is not the record.
- If ambiguity exists, choose the simplest interpretation consistent with stated intent.
- Document the assumption or decision in `results.md`.
- Never silently guess.
- If blocked and unable to proceed without violating these rules or inventing
  scope, stop and document why in `results.md`.

---

## Output Discipline

- Output only what is required by your role.
- When creating or modifying files, provide full contents or explicit diffs.
- Do not include commentary outside of required artifacts.

---

## Logging & Traceability

- Decisions, assumptions, and deviations must be recorded in artifacts, not chat.
- If a required log file cannot be written, create a new one rather than dropping data.
- Partial completion must still be documented.

---

## Failure Handling

- Failure is acceptable.
- Silent failure is not.
- If you cannot proceed without violating these rules, stop and document why in `results.md`.

---

## Default Stance

Be conservative.
Be explicit.
Be auditable.