# CLAUDE.md

All engineering rules are in **[AGENTS.md](AGENTS.md)** — read it first and
follow it. This file only describes how Claude Code works in this repository.

## Workflow per phase

1. State the goal of the phase and the files to be touched.
2. Implement in small, verifiable steps.
3. Regenerate code when needed (see `docs/TESTING.md`).
4. Run `dart format .`, `flutter analyze`, `flutter test`.
5. Fix every issue; never report unrun or failing checks as passing.
6. Report: **Completed / Files / Tests / Issues / Next**.
7. Wait for the owner's approval before starting the next phase.

## Ground rules

- Read existing files before modifying or deleting them.
- Ask before architectural changes that alter the project goal.
- Commit locally after a completed phase; **do not push without explicit
  approval**. Repository visibility, releases and published builds change
  only with the owner's explicit approval.
- Verify package APIs and versions against pub.dev / official docs.

## Useful references

- Architecture: `docs/ARCHITECTURE.md`
- Database: `docs/DATABASE.md`
- Design system: `docs/DESIGN_SYSTEM.md`
- Features & acceptance criteria: `docs/FEATURES.md`
- Test commands: `docs/TESTING.md`
