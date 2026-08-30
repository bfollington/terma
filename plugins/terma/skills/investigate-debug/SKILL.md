---
name: investigate-debug
description: Evidence-driven investigation and debugging framework for long-running, iterative, or ambiguous technical problems. Use when Codex needs to investigate failures, regressions, flaky behavior, performance problems, production incidents, unclear user reports, unknown root causes, or any scientific debugging session where evidence, hypotheses, experiments, findings, and context-resilient notes must be maintained across turns or context compaction.
---

# Investigate Debug

## Overview

Run the investigation as a scientific loop: gather evidence, form explicit hypotheses, test them with targeted experiments, and maintain a durable log that another agent or future compacted context can resume from. Do not blindly follow a fixed checklist; adapt the process to the problem and the evidence.

## Core Rules

- Keep an investigation log from the start. Prefer a repo-local or user-specified file when appropriate; otherwise keep a concise running log in conversation and summarize it at checkpoints.
- Separate observations from inference. Label facts, hypotheses, experiments, results, decisions, and open questions distinctly.
- Preserve negative results. Failed theories, dead ends, and disproven assumptions are useful evidence.
- Test the highest-information hypothesis available, not the easiest command by habit.
- Ask the user targeted questions only when the answer would materially change the next experiment or risk profile.
- Do not treat the framework as a script. Skip, reorder, or repeat sections based on the investigation state.
- Before major edits or fixes, state the theory being acted on and the evidence supporting it.
- If context may compact, leave a restartable checkpoint with current state, leading hypotheses, ruled-out paths, and next experiments.

## Investigation Log

Use this compact structure, adapting labels as needed:

```markdown
# Investigation Log: <problem>

## Problem
- User-visible symptom:
- Scope / impact:
- Constraints:

## Known Facts
- [fact] Source:

## Hypotheses
- H1: <claim> | confidence: low/med/high | evidence for/against:

## Experiments
- E1: <command/action> | tests: H<n> | expected if true: | result: | conclusion:

## Decisions / Changes
- Decision:
- Rationale:
- Files / systems touched:

## Open Questions
- Question:
- Why it matters:

## Checkpoint
- Current understanding:
- Ruled out:
- Most likely next step:
- Resume command/context:
```

For repo work, create a log only when it will help the session survive multiple turns, complex branching, or compaction. Use a path the user asked for, a repo convention if one exists, or a temporary local note if no durable artifact is appropriate. Do not create process clutter for a short investigation.

## Workflow

1. Frame the problem.
   - Restate the symptom, expected behavior, observed behavior, constraints, and stakes.
   - Identify what would count as proof, reproduction, mitigation, or completion.

2. Gather baseline evidence.
   - Inspect current state before changing it: relevant files, logs, tests, configuration, environment, recent changes, and user reports.
   - Record commands/actions and key outputs. Summarize noisy output instead of pasting large logs.

3. Build competing hypotheses.
   - Keep at least two plausible explanations when the evidence is thin.
   - Note what each hypothesis predicts and what observation would falsify it.

4. Run targeted experiments.
   - Prefer small experiments that distinguish between hypotheses.
   - Change one meaningful variable at a time when practical.
   - Record expected result before running the experiment when the prediction is useful.

5. Update beliefs.
   - After each result, mark hypotheses as strengthened, weakened, falsified, or still ambiguous.
   - Add new facts and retire stale assumptions explicitly.

6. Intervene when justified.
   - Implement fixes only after the evidence points to a likely cause or the user explicitly asks for exploratory changes.
   - Keep changes scoped to the theory. Add or update tests that capture the behavior when the task involves code.

7. Verify and close.
   - Re-run the relevant reproduction, tests, or checks.
   - Record the final root cause, fix, verification, residual risk, and any follow-up work.

## Collaboration

- Keep the user informed with concise updates when investigations run long.
- Ask for missing context when local evidence cannot answer a question safely: symptoms, timeline, deployment/version, recent changes, reproduction details, acceptable risk, or access constraints.
- Offer a decision point when there are multiple reasonable next experiments with different cost, risk, or user involvement.
- When blocked, summarize exactly what is known, what was tried, why it is blocked, and what input or permission would unblock it.

## Checkpointing

Create a checkpoint whenever the investigation changes phase, reaches a non-obvious conclusion, runs longer than the current context can safely hold, or pauses for user input. A useful checkpoint lets a fresh agent continue without repeating work:

```markdown
Checkpoint:
- Symptom:
- Evidence gathered:
- Current leading theory:
- Hypotheses ruled out:
- Experiments run:
- Changes made:
- Verification status:
- Next best experiments:
- User decisions needed:
```
