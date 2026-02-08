# Generate Breadcrumb

Generate a new breadcrumb snapshot of current thinking state using SQLite notes.

## Arguments
- `$ARGUMENTS` - Optional: context about what this session focused on (e.g., "article refinement", "conversation with @gozala")

## Process

### 1. Read Recent Breadcrumbs

Query existing breadcrumbs to understand the thinking trail:

```bash
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, summary, themes, momentum, generated_at
FROM breadcrumbs
ORDER BY generated_at DESC
LIMIT 5;
SQL
```

Note the most recent breadcrumb ID - you'll reference it via `prev_breadcrumb_id`.

### 2. Identify Recent Notes

Query recent notes (especially inbox) to understand what's been captured:

```bash
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, body, folder, tags, captured_at
FROM notes
WHERE folder IN ('inbox', 'working')
  AND captured_at >= date('now', '-7 days')
ORDER BY captured_at DESC;
SQL
```

Also consider notes modified recently or tagged with session-relevant themes.

### 3. Analyze the Session

Based on recent notes and the user's context ($ARGUMENTS), identify:

- **Summary**: 2-3 sentences capturing the session's intellectual movement
- **Themes**: 3-6 key themes that emerged (short phrases)
- **Connections**: How ideas link to each other and to previous breadcrumbs
- **Questions**: 3-5 open questions that surfaced or remain unresolved
- **Momentum**: One of:
  - `exploring` - divergent, opening up new territory
  - `converging` - ideas crystallizing, refining toward clarity
  - `scattered` - multiple threads, not yet unified
  - `dormant` - consolidation period, not much movement
  - `breakthrough` - major insight or synthesis achieved

### 4. Create the Breadcrumb

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO breadcrumbs (
  id, summary, themes, connections, questions, momentum,
  window_start, window_end, notes_considered, prev_breadcrumb_id, generated_at
)
VALUES (
  'BC-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  '<2-3 sentence summary>',
  json_array('theme1', 'theme2', 'theme3'),
  '<paragraph describing how ideas connect>',
  json_array('Question 1?', 'Question 2?', 'Question 3?'),
  'exploring',
  (SELECT COALESCE(
    (SELECT generated_at FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
    strftime('%Y-%m-%dT%H:%M:%SZ', date('now', '-7 days'))
  )),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now'),
  (SELECT COUNT(*) FROM notes WHERE captured_at >= date('now', '-7 days')),
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL
```

### 5. Batch Link to Analyzed Notes

Link the new breadcrumb to all notes it analyzed in one query:

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  notes.id,
  'analyzedNotes'
FROM notes
WHERE folder IN ('inbox', 'working')
  AND captured_at >= date('now', '-7 days');
SQL
```

### 6. Report Summary

Return to the user:
- Breadcrumb ID created
- Summary of themes and momentum
- Key questions surfaced
- The trail so far (list of breadcrumbs in sequence)

Query the trail:

```bash
sqlite3 -header -column .sqlite/notes.db <<'SQL'
WITH RECURSIVE trail AS (
  SELECT id, summary, momentum, generated_at, prev_breadcrumb_id, 1 AS pos
  FROM breadcrumbs
  ORDER BY generated_at DESC LIMIT 1

  UNION ALL

  SELECT bc.id, bc.summary, bc.momentum, bc.generated_at, bc.prev_breadcrumb_id, trail.pos + 1
  FROM trail
  JOIN breadcrumbs bc ON trail.prev_breadcrumb_id = bc.id
  WHERE trail.pos < 5
)
SELECT id, momentum, substr(summary, 1, 50) AS summary_preview
FROM trail
ORDER BY pos DESC;
SQL
```

## Example Output

```
Breadcrumb created: BC-20260125-a8f9b3c2

Momentum: converging

Themes:
- Feedback as essential friction
- Tight loops squeeze out emergence
- Factory-thinking neglects design

Questions:
1. How do you institutionalize good friction?
2. What would a feedback-aware orchestrator look like?

Trail:
BC-20260119-x7k9m2n5 (converging) → BC-20260119-p8q2r4s6 (breakthrough) → BC-20260125-a8f9b3c2 (converging)
```

## Notes

- The `prev_breadcrumb_id` FK maintains the trail automatically
- The breadcrumb captures a *snapshot* of thinking - it's okay if it's incomplete
- Momentum is subjective - use your judgment based on the session's feel
- Questions are valuable - they point toward future exploration
- Batch linking with INSERT...SELECT is much more efficient than individual inserts
