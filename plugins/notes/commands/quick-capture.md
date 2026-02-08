# Quick Capture - SQLite Notes Ingestion

Ingest loose notes into the SQLite notes database at `.sqlite/notes.db`.

## Arguments
- `$ARGUMENTS` - The raw notes to capture (can be messy, hierarchical, bullet points, stream of consciousness)

## Process

### 1. Analyze and Chunk
Read the input and identify distinct **ideas**, not fragments. The goal is index cards (zettelkasten), not post-it notes.

**Index card test**: Can this note stand alone and say something meaningful? Does it have enough context to be useful when encountered later?

**Too granular** (post-it):
> "Less state machine, more differential equations"

**Right granularity** (index card):
> "Less state machine, more differential equations - the system evolves continuously based on conditions, not discrete transitions. Small changes to ontology yield large effects because you're shaping a possibility space, not defining fixed states."

### 2. Propose Chunking to User
Before creating notes, present the proposed breakdown:
- List each proposed note with a title and 1-sentence summary
- Identify theme clusters
- Ask user to confirm or adjust granularity

### 3. Create Notes
For each approved chunk, create a note in the inbox:

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, title, body, folder, origin, tags, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Title here',
  'Content here',
  'inbox',
  'me',
  json_array('tag1', 'tag2'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL
```

**Note ID format**: `N-YYYYMMDD-xxxxxxxx` (date + 8 random hex chars)

### 4. Link Related Notes
Query existing notes to find connections:

```bash
# List inbox notes
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"

# All notes with id and title
sqlite3 -header -column .sqlite/notes.db "SELECT id, title FROM notes ORDER BY captured_at DESC;"
```

Create links between related notes:

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO links (source_id, target_id, rel_type)
VALUES ('N-20260208-a1b2c3d4', 'N-20260207-e5f6g7h8', 'linksTo');
SQL
```

### 5. Offer Breadcrumb Generation
After capture, ask the user if they want a breadcrumb generated. If yes:

1. Query all recent notes
2. Analyze themes, connections, questions, and momentum
3. Create a breadcrumb:

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO breadcrumbs (
  id, summary, themes, connections, questions, momentum,
  window_start, window_end, notes_considered, prev_breadcrumb_id, generated_at
)
VALUES (
  'BC-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Summary of recent thinking...',
  json_array('theme1', 'theme2'),
  'How ideas connect...',
  json_array('Question 1?', 'Question 2?'),
  'exploring',
  strftime('%Y-%m-%dT%H:%M:%SZ', date('now', '-7 days')),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now'),
  5,
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL
```

4. Batch link breadcrumb to analyzed notes:

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  notes.id,
  'analyzedNotes'
FROM notes
WHERE folder = 'inbox'
  AND captured_at >= date('now', '-7 days');
SQL
```

## Key Principles

- **Capture-heavy, not pristine**: Get ideas in, refine later
- **Origin tracking**: Always set `origin: me` for user content, `origin: llm` for AI-generated
- **Inbox first**: Everything starts in inbox, moves to working/permanent during review
- **Links over tags**: Explicit links between notes are more valuable than shared tags
- **Breadcrumbs for continuity**: Regular breadcrumbs maintain thinking trails across sessions

## Useful Commands

```bash
# List inbox (use view)
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"

# Delete a note
sqlite3 .sqlite/notes.db "DELETE FROM notes WHERE id = 'N-20260208-a1b2c3d4';"

# Find notes by tag
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, tags FROM notes
WHERE EXISTS (SELECT 1 FROM json_each(tags) WHERE value = 'theme');
SQL

# Full-text search
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT n.id, n.title, snippet(notes_fts, 1, '**', '**', '...', 30) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'search term'
ORDER BY rank;
SQL
```
