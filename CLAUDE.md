# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

This repository is currently in the **Intent → Spec** phase of a structured product workflow; no application code exists yet (the `.gitignore` is a standard Python template, anticipating a Python implementation, but nothing has been built). Do not assume a build/lint/test toolchain — there isn't one yet. Once a Build phase starts and real tooling is added, this file should be updated with the actual commands.

## The Intent → Spec → Build workflow

Work on this project moves through three phases, each gated by human (Product Owner) approval via a merged pull request to `main`:

1. **Intent** (`intent/<slug>/intent.md`) — a structured statement of the problem, proposed outcome, affected users/systems, and constraints, written by the `intent` skill (`.claude/skills/intent/SKILL.md`). No product decisions or technical solutions are invented here; unresolved points go in `Questions ouvertes`.
2. **Spec** (`intent/<slug>/spec.md`) — requirements and proposed design derived strictly from an *accepted* intent, written by the `spec` skill (`.claude/skills/spec/SKILL.md`). Each requirement (`EX-NN`) traces back to a specific passage in the intent and has a concrete scenario (starting situation / action / expected observable result). Open ambiguities are tracked as `Réserves` (reservations) and resolved one at a time with the Product Owner — never decided unilaterally.
3. **Build** (not started yet) — implementation, which is expected to be driven by a future skill/phase not yet present in this repo.

Both existing skills are French-language and encode strict process rules that any future work in this repo should respect:

- **Never decide product questions on the author's/Product Owner's behalf.** Ambiguities are recorded as open questions or reservations, not resolved by assumption.
- **Never commit, push, or open a pull request without explicit human confirmation** at the relevant checkpoint. Commits are scoped only to the file(s) belonging to the phase being worked (e.g., only `intent.md` during the Intent phase).
- **Work happens on a dedicated branch per phase**, created from the latest accepted state on `main` (naming convention for intents: `claude/intent-<slug>`). If branch creation fails, stop and explain rather than working directly on `main`.
- **Never merge the pull requests this workflow opens** — merging is the Product Owner's action, done outside the skill.
- Each phase's document ends with a "Contexte de génération" section recording the exact prompt/command used and the git commit of the skill version applied, so the generation is reproducible/auditable. Preserve this section (and add to it, don't replace it) on revisions.

## Current domain content

`intent/mars-rover/intent.md` and `intent/mars-rover/spec.md` describe a CLI Mars rover simulator: given a starting position/orientation, a map with obstacles, and a command sequence, it moves the rover (forward / turn left / turn right), stops it before obstacles (including map edges, per decision EX-08), and reports final position/orientation plus whether it was blocked. Inputs are read from file(s) passed as program arguments (EX-09); invalid input must be detected and reported as an error rather than executed (EX-10, reservation R-02). The spec's "Conception proposée" section defers implementation-level details (exact file layout, message wording) to the Build phase — treat those as free to decide there, not as open product questions.
