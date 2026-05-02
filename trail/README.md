Trail Framework — Scaffold
Your first run in 30 minutes.
Full documentation: trail.venturanomadica.com

What's in this folder
trail/
├── meta/
│   ├── trail.md                          ← product identity (fill this in)
│   ├── baseline.md                       ← current state of the project
│   ├── global-operating-instructions.md  ← policy for all executors
│   ├── files/                            ← shared project inputs
│   ├── prompts/                          ← utility prompts
│   └── templates/                        ← starting points for intents
├── intents/                              ← one folder per intent
└── runs/                                 ← execution artifacts, grouped by intent

Step 1 — Fill in your meta files (5 minutes)
Edit trail/meta/trail.md — describe your product: what it is, who it's for,
permanent constraints, and product principles. The Manager reads this on every run.
If this is an existing project, generate your baseline:

This is an existing project. Execute the instructions in
trail/meta/prompts/generate-baseline.md.

If this is a new project, baseline.md can stay blank for now.

Step 2 — Write your intent (15 minutes)
Copy the three templates from trail/meta/templates/intent-package/ into
trail/intents/intent-0001/.
Fill in intent.md. This is the only document in Trail that is 100%
human-authored — take your time here. Friction upfront means less friction later.
Leave manager-instructions.md as-is unless you need to change run policy.
Leave operating-instructions-override.md as "None" unless this intent needs
different policy from global.

Step 3 — Run the Manager
Open a new AI chat. Provide:

trail/meta/global-operating-instructions.md
trail/intents/intent-0001/intent.md
trail/intents/intent-0001/manager-instructions.md
trail/intents/intent-0001/operating-instructions-override.md

Prompt:

You are acting as the Trail Manager for this intent. Read all provided
files and produce the run bundle per manager-instructions.md.

The Manager returns one of:

READY_FOR_DEV — run bundle produced, save files to trail/runs/intent-0001/run-01/
INTENT_UNUSABLE — something is missing or contradictory, fix the intent and retry


Step 4 — Review the run bundle
Before handing off to the Developer, verify:

tasks.md — do the tasks match your intent?
operating-instructions.md — does the policy look right?
dev-prompt.md — are inputs and outputs correct?

This is Human Checkpoint A. Nothing proceeds without your approval.

Step 5 — Run the Developer
Copy dev-prompt.md into a new AI chat (or hand to a human executor).
The Developer executes the tasks and produces the deliverable plus a
populated results.md.

Step 6 — Review and close
Review output against intent.md, tasks.md, and results.md.

Accepted → intent is done. Start a new intent for the next piece of work.
Fixes needed → create run-02 under the same intent.
Scope is wrong → create a new intent.


License
Documentation — CC BY 4.0
Scaffold — MIT
© 2026 Ventura Nomadica