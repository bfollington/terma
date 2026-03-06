---
name: orient
description: Explore and understand a new or unfamiliar codebase by mapping its directory structure, identifying entry points, analyzing dependencies, and locating key configuration files. Use when onboarding to a new repo, getting started with an unfamiliar project, or asked to understand this codebase — including code exploration, repository orientation, and navigating project architecture.
---

Read and apply the guidance from @../../lib/subagent.md

# Orient

Read `README.md` first, then systematically explore the project's structure and functionality using the steps below. Write a report to brief the lead project agent so we can get to work.

## Exploration Steps

Work through these in order, fanning out as needed based on what you find:

1. **README & docs** — Read `README.md`. Check for a `docs/` directory, `CONTRIBUTING.md`, `CHANGELOG.md`, or `ARCHITECTURE.md`.
2. **Package & dependency manifests** — Look for `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, or equivalent. Note the tech stack and key dependencies.
3. **Build & task configuration** — Check for `Makefile`, `Taskfile`, `justfile`, `.github/workflows/`, `Dockerfile`, `docker-compose.yml`, and similar. Note how the project is built, tested, and deployed.
4. **Directory layout** — Survey top-level directories (`src/`, `lib/`, `app/`, `tests/`, `scripts/`, etc.) to understand the overall layout.
5. **Entry points** — Identify the main entry point(s): `main.*`, `index.*`, `app.*`, `server.*`, or whatever the manifest points to.
6. **Core modules** — Briefly read the most central source files to understand dominant patterns (framework choice, data models, API surface, etc.).
7. **Configuration** — Note environment config (`.env.example`, `config/`, settings files) and any secrets management.
8. **Tests** — Glance at the test directory to understand the testing approach and coverage posture.

## Report Template

Produce a structured report covering:

```
## Project: <name>

### Overview
One-paragraph summary of what the project does and who it is for.

### Tech Stack
- Language(s): ...
- Frameworks / libraries: ...
- Databases / external services: ...
- Build / task tooling: ...

### Repository Layout
Brief description of top-level directories and their purpose.

### Entry Points
List the main entry point(s) and how to run the project locally.

### Key Dependencies
Highlight the most important or unusual dependencies.

### Architecture Patterns
Describe dominant patterns (e.g. MVC, event-driven, microservices, monorepo, etc.).

### Testing Approach
Test framework, location of tests, and rough coverage posture.

### Open Questions / Gaps
Anything unclear, missing, or that needs follow-up before starting work.
```
