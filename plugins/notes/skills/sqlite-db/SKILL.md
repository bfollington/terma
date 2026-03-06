---
name: sqlite-db
description: General guide for using the sqlite3 CLI to build composable knowledge databases. Use this skill when creating SQLite databases, designing schemas with CREATE TABLE, defining foreign keys and indexes, running CLI queries, importing or exporting data (CSV/JSON), managing structural and graph relationships, or building new sqlite-based domain skills. Provides foundational patterns — for domain-specific workflows (e.g., a notes or task tracker schema), prefer a dedicated sqlite domain skill if one exists; use this skill for general-purpose sqlite operations and cross-domain patterns.
---

# SQLite Database Skills

**Composable knowledge databases via raw SQL.**

The `sqlite3` CLI provides direct access to the full power of relational SQL: indexes, joins, aggregations, window functions, CTEs, full-text search, JSON functions, triggers, and views. Each domain gets its own `.db` file. Always pass the database path explicitly — stateless, deterministic per invocation.

## Database Targeting

```bash
# Single-line command
sqlite3 /path/to/mydata.db "SELECT * FROM notes WHERE status = 'active';"

# Multi-line command via heredoc
sqlite3 /path/to/mydata.db <<'SQL'
SELECT id, title, created_at
FROM notes
WHERE status = 'active'
ORDER BY created_at DESC;
SQL
```

## Output Modes

Use **column mode** for human-readable output and **JSON mode** for scripting:

```bash
# Human-readable (column mode)
sqlite3 -header -column /path/to/mydata.db "SELECT id, title, status FROM notes LIMIT 10;"

# JSON for scripting/piping to jq
sqlite3 /path/to/mydata.db <<'SQL'
.mode json
SELECT id, title, tags FROM notes WHERE status = 'active';
SQL

sqlite3 /path/to/mydata.db "SELECT ..." | jq -r '.[] | select(.status == "active") | .id'

# Single record inspection (-line mode)
sqlite3 -line /path/to/mydata.db "SELECT * FROM notes WHERE id = 'NOTE-...';"

# CSV export
sqlite3 -csv -header /path/to/mydata.db "SELECT ..." > export.csv
```

## Core Operations

### Initialize a Database

```bash
mkdir -p /path/to/.sqlite

sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'archived')) DEFAULT 'draft',
  tags TEXT CHECK (json_valid(tags)),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_notes_status ON notes(status);
CREATE INDEX IF NOT EXISTS idx_notes_created ON notes(created_at DESC);
SQL
```

**Important pragmas:**
- `PRAGMA journal_mode = WAL;` — enables concurrent reads and better performance
- `PRAGMA foreign_keys = ON;` — enforces referential integrity

### Generate IDs

Use inline SQL expressions to generate unique, time-ordered, human-readable IDs:

```sql
'PREFIX-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4)))
```

**Examples:**
- `'NOTE-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4)))` → `NOTE-20260208-a3f8c291`
- `'TASK-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4)))` → `TASK-20260208-7b2e9f41`

**Prefix conventions:** `NOTE-`, `TASK-`, `RES-`, `CLIP-`, `CRUMB-`, `REFL-`

### Create Records

```bash
sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
INSERT INTO notes (id, title, body, status, tags)
VALUES (
  'NOTE-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Understanding Composability',
  'Systems that compose are systems that scale...',
  'active',
  json_array('systems', 'design', 'composability')
);
SQL
```

**Note:** Use `json_array()` for JSON array fields, not string concatenation.

### Query Records

```bash
sqlite3 -header -column /path/to/.sqlite/mydata.db <<'SQL'
SELECT id, title, status, created_at
FROM notes
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT 10;
SQL
```

**Pagination:**

```sql
SELECT id, title
FROM notes
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;  -- Page 3 (20 per page)
```

**JSON output for scripting:**

```bash
sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
.mode json
SELECT id, title, tags FROM notes WHERE status = 'active';
SQL
```

### Show a Record

```bash
sqlite3 -line /path/to/.sqlite/mydata.db "SELECT * FROM notes WHERE id = 'NOTE-20260208-a3f8c291';"
```

Output:
```
        id = NOTE-20260208-a3f8c291
     title = Understanding Composability
      body = Systems that compose are systems that scale...
    status = active
      tags = ["systems","design","composability"]
created_at = 2026-02-08 14:32:01
updated_at = 2026-02-08 14:32:01
```

### Update Records

**Workflow:**

1. Run the UPDATE:

```bash
sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
UPDATE notes
SET
  status = 'archived',
  updated_at = datetime('now')
WHERE id = 'NOTE-20260208-a3f8c291';
SQL
```

2. Verify the change before proceeding:

```bash
sqlite3 -line /path/to/.sqlite/mydata.db "SELECT id, status, updated_at FROM notes WHERE id = 'NOTE-20260208-a3f8c291';"
```

**Batch update — always verify row counts:**

1. Preview rows affected:

```sql
SELECT COUNT(*) FROM notes WHERE created_at < date('now', '-1 year');
```

2. Run the batch update:

```sql
UPDATE notes
SET status = 'archived', updated_at = datetime('now')
WHERE created_at < date('now', '-1 year');
```

3. Confirm results:

```sql
SELECT status, COUNT(*) FROM notes GROUP BY status;
```

### Delete Records

**Workflow:**

1. Preview what will be deleted:

```bash
sqlite3 /path/to/.sqlite/mydata.db "SELECT id, title FROM notes WHERE id = 'NOTE-20260208-a3f8c291';"
```

2. Run the DELETE:

```bash
sqlite3 /path/to/.sqlite/mydata.db "DELETE FROM notes WHERE id = 'NOTE-20260208-a3f8c291';"
```

3. Verify deletion (must return 0):

```bash
sqlite3 /path/to/.sqlite/mydata.db "SELECT COUNT(*) FROM notes WHERE id = 'NOTE-20260208-a3f8c291';"
```

Only proceed with downstream operations once count confirms 0.

## Relationships

SQLite supports two relationship styles, each with distinct use cases.

### Structural Relationships (Foreign Key Columns)

Use foreign key columns for parent-child ownership and 1:1 or N:1 relationships:

```sql
CREATE TABLE clippings (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  resource_id TEXT,
  clipped_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE
);

CREATE INDEX idx_clippings_resource ON clippings(resource_id);
```

**Query pattern:**

```sql
-- All clippings from a specific resource
SELECT c.id, c.content, c.clipped_at
FROM clippings c
WHERE c.resource_id = 'RES-20260208-f1a2b3c4';

-- Join to get resource details
SELECT c.id, c.content, r.title AS resource_title
FROM clippings c
JOIN resources r ON c.resource_id = r.id
WHERE r.status = 'finished';
```

### Flexible Relationships (Links Table)

Use a generic `links` table for many-to-many, ad-hoc, named relationships:

```sql
CREATE TABLE links (
  source_id TEXT NOT NULL,
  target_id TEXT NOT NULL,
  rel_type TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (source_id, target_id, rel_type)
);

CREATE INDEX idx_links_source ON links(source_id, rel_type);
CREATE INDEX idx_links_target ON links(target_id, rel_type);
```

**Create links:**

```sql
-- Single link
INSERT INTO links (source_id, target_id, rel_type)
VALUES ('NOTE-20260208-a3f8c291', 'NOTE-20260205-b2c3d4e5', 'linksTo');

-- Batch link creation
INSERT INTO links (source_id, target_id, rel_type)
SELECT 'CRUMB-20260208-f1f2f3f4', id, 'analyzedNotes'
FROM notes
WHERE tags LIKE '%systems%' AND created_at > date('now', '-7 days');
```

**Query outgoing links:**

```sql
SELECT l.rel_type, n.id, n.title
FROM links l
JOIN notes n ON l.target_id = n.id
WHERE l.source_id = 'NOTE-20260208-a3f8c291';
```

**Query incoming links:**

```sql
SELECT l.rel_type, n.id, n.title
FROM links l
JOIN notes n ON l.source_id = n.id
WHERE l.target_id = 'NOTE-20260208-a3f8c291';
```

**Remove links:**

```sql
DELETE FROM links
WHERE source_id = 'NOTE-20260208-a3f8c291'
  AND target_id = 'NOTE-20260205-b2c3d4e5'
  AND rel_type = 'linksTo';
```

**Common relationship types:**
- `linksTo` — general connection
- `derivedFrom` — content derived from another note
- `partOf` — belongs to a container/collection
- `analyzedNotes` — breadcrumb analyzed these notes
- `basedOnNotes` — reflection based on these notes
- `promotedTo` — reflection promoted to note

## Views as Saved Queries

Views support joins, aggregations, and can reference other views.

```sql
-- Create
CREATE VIEW active_notes AS
SELECT id, title, status, created_at
FROM notes
WHERE status = 'active'
ORDER BY created_at DESC;

-- Query
SELECT * FROM active_notes LIMIT 10;

-- List all views
SELECT name FROM sqlite_master WHERE type = 'view';

-- Drop
DROP VIEW IF EXISTS active_notes;
```

**Complex view example — note graph with link counts:**

```sql
CREATE VIEW note_graph AS
SELECT
  n.id,
  n.title,
  n.status,
  COUNT(DISTINCT lo.target_id) AS outgoing_links,
  COUNT(DISTINCT li.source_id) AS incoming_links
FROM notes n
LEFT JOIN links lo ON n.id = lo.source_id
LEFT JOIN links li ON n.id = li.target_id
GROUP BY n.id, n.title, n.status;
```

## Triggers for Automation

### Auto-Update Timestamps

```sql
CREATE TRIGGER update_notes_timestamp
AFTER UPDATE ON notes
FOR EACH ROW
BEGIN
  UPDATE notes SET updated_at = datetime('now') WHERE id = OLD.id;
END;
```

### FTS Sync Triggers

See "Full-Text Search" section below.

## Full-Text Search (FTS5)

### Create FTS Virtual Table

```sql
CREATE VIRTUAL TABLE notes_fts USING fts5(
  id UNINDEXED,
  title,
  body,
  tags,
  content='notes',
  content_rowid='rowid'
);
```

### Sync Triggers

```sql
CREATE TRIGGER notes_fts_insert AFTER INSERT ON notes BEGIN
  INSERT INTO notes_fts(rowid, id, title, body, tags)
  VALUES (NEW.rowid, NEW.id, NEW.title, NEW.body, NEW.tags);
END;

CREATE TRIGGER notes_fts_update AFTER UPDATE ON notes BEGIN
  UPDATE notes_fts
  SET title = NEW.title, body = NEW.body, tags = NEW.tags
  WHERE rowid = OLD.rowid;
END;

CREATE TRIGGER notes_fts_delete AFTER DELETE ON notes BEGIN
  DELETE FROM notes_fts WHERE rowid = OLD.rowid;
END;
```

### Search Queries

```sql
-- Simple search
SELECT id, title FROM notes_fts WHERE notes_fts MATCH 'composability';

-- Boolean operators
SELECT id, title FROM notes_fts WHERE notes_fts MATCH 'systems AND composability';

-- Phrase search
SELECT id, title FROM notes_fts WHERE notes_fts MATCH '"knowledge management"';

-- Ranked search with snippets
SELECT
  n.id,
  n.title,
  snippet(notes_fts, 1, '**', '**', '...', 32) AS snippet,
  bm25(notes_fts) AS rank
FROM notes_fts
JOIN notes n ON notes_fts.id = n.id
WHERE notes_fts MATCH 'composability'
ORDER BY rank
LIMIT 10;
```

## JSON Functions

### Creating and Querying JSON Arrays

```sql
-- Store as JSON array
INSERT INTO notes (id, title, tags)
VALUES (
  'NOTE-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Example Note',
  json_array('tag1', 'tag2', 'tag3')
);

-- Check if array contains a value
SELECT id, title
FROM notes
WHERE EXISTS (
  SELECT 1 FROM json_each(notes.tags)
  WHERE json_each.value = 'systems'
);

-- Extract unique tags across all notes
SELECT DISTINCT json_each.value AS tag
FROM notes, json_each(notes.tags)
WHERE notes.status = 'active'
ORDER BY tag;

-- Tag cloud
SELECT json_each.value AS tag, COUNT(*) AS note_count
FROM notes, json_each(notes.tags)
GROUP BY json_each.value
ORDER BY note_count DESC;
```

### Updating JSON Arrays

```sql
-- Add a tag
UPDATE notes
SET tags = json_insert(tags, '$[#]', 'new-tag')
WHERE id = 'NOTE-20260208-a3f8c291';

-- Remove a tag
UPDATE notes
SET tags = (
  SELECT json_group_array(value)
  FROM json_each(notes.tags)
  WHERE value != 'old-tag'
)
WHERE id = 'NOTE-20260208-a3f8c291';
```

### JSON Validation

Use `json_valid()` in CHECK constraints:

```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  tags TEXT CHECK (json_valid(tags)),
  metadata TEXT CHECK (json_valid(metadata) OR metadata IS NULL)
);
```

## CHECK Constraints for Validation

```sql
-- Enum-style
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'archived')) DEFAULT 'draft',
  epistemic TEXT CHECK (epistemic IN ('hypothesis', 'tested', 'validated', 'outdated'))
);

-- Range
CREATE TABLE resources (
  id TEXT PRIMARY KEY,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);

-- Pattern (SQLite has no native regex in CHECK)
CREATE TABLE resources (
  id TEXT PRIMARY KEY,
  url TEXT CHECK (url LIKE 'http%')
);
```

For complex validation, use application-level checks before INSERT.

## Aggregations

```sql
-- Notes per status
SELECT status, COUNT(*) AS count FROM notes GROUP BY status;

-- Monthly note creation counts
SELECT
  strftime('%Y-%m', created_at) AS month,
  COUNT(*) AS note_count
FROM notes
GROUP BY month
ORDER BY month DESC;

-- Tag cloud with percentages (window function)
WITH tag_counts AS (
  SELECT json_each.value AS tag, COUNT(*) AS count
  FROM notes, json_each(notes.tags)
  GROUP BY json_each.value
)
SELECT
  tag,
  count,
  ROUND(100.0 * count / SUM(count) OVER (), 2) AS percentage
FROM tag_counts
ORDER BY count DESC
LIMIT 20;
```

## Building a SQLite-DB Skill

Specialized sqlite-db skills follow a consistent structure:

### Directory Layout

```
skills/sqlite-<domain>/
├── SKILL.md                # Instructions, workflows, SQL examples
├── assets/
│   ├── schema.sql          # DDL: tables, indexes, FTS, triggers
│   └── views.sql           # Reusable views
├── scripts/
│   ├── setup.sh            # Idempotent initialization script
│   └── examples.sh         # Demo workflows
└── references/
    └── queries.md          # Complex query recipes
```

### What a SQLite Skill Should Define

1. **Tables** — DDL with constraints, indexes, and foreign keys
2. **Indexes** — B-tree indexes for common queries, FTS for search
3. **Views** — Saved queries as first-class database objects
4. **Triggers** — Auto-timestamps, FTS sync
5. **Links vocabulary** — Named relationship types
6. **Database path** — Where the `.db` file lives
7. **ID prefixes** — Conventions for human-readable IDs
8. **Workflows** — Step-by-step SQL examples for common tasks

### Design Principles

- **Schemas encode domain knowledge.** DDL is documentation. Use meaningful column names, CHECK constraints, foreign keys, and indexes.
- **Target database explicitly.** Every `sqlite3` command specifies the full path. Stateless invocation only.
- **Views are your menu.** Create views for common queries; they compose and can reference other views.
- **Use both relationship styles.** Foreign keys for ownership, links table for ad-hoc graph relationships.
- **Include setup scripts.** Provide an idempotent `setup.sh` that initializes a working database with one command.
- **Always verify destructive operations.** Follow every DELETE and batch UPDATE with a confirming SELECT or COUNT before proceeding.
