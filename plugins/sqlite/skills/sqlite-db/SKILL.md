---
name: sqlite-db
description: General guide for using the sqlite3 CLI to build composable knowledge databases. Use this skill when creating SQLite databases, designing schemas, querying data, managing relationships, or building new sqlite-based domain skills. Provides the foundational patterns that all specialized sqlite skills build upon.
---

# SQLite Database Skills

**Composable knowledge databases via raw SQL.**

SQLite databases are portable, self-contained, and require no server. The `sqlite3` CLI provides direct access to the full power of relational SQL: indexes, joins, aggregations, window functions, CTEs, full-text search, JSON functions, triggers, and views. This skill teaches agents how to use SQLite as a knowledge management substrate.

## Philosophy

### SQL is the Interface

No wrapper, no abstraction layer. You compose SQL directly. This gives you the full power of SQLite: complex joins, window functions, CTEs, FTS5, JSON operations, triggers, and views. Verbosity costs tokens, not keystrokes — and the expressiveness pays dividends.

### Schemas Are the DDL

No YAML declarations. The `CREATE TABLE` statements *are* the schema. Run `.schema` to see everything. Column types, constraints, foreign keys, indexes — all visible in the DDL. Self-documenting by design.

### Composable .db Files

Each domain gets its own `.db` file. Your notes database, investment tracker, and issue tracker are separate files. Portable — copy, share, back up independently. No central server required.

### Agent-Compatible

The `sqlite3` CLI is deterministic and stateless per invocation. Output modes (`-header -column`, `.mode json`, `-line`) are parseable. Commands never rely on session state. Perfect for LLM-driven workflows.

## Database Targeting

**Always pass the database path as the first argument to `sqlite3`.** This ensures stateless, deterministic behavior.

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

Choose the output mode based on your needs:

| Mode | Use Case | Invocation |
|------|----------|------------|
| **Column** | Human-readable tables | `sqlite3 -header -column mydata.db "SELECT ..."` |
| **JSON** | Agent parsing with jq | `sqlite3 mydata.db "SELECT ..." \| jq` (after `.mode json`) |
| **CSV** | Export to spreadsheets | `sqlite3 -csv -header mydata.db "SELECT ..."` |
| **Line** | Single record inspection | `sqlite3 -line mydata.db "SELECT * FROM notes WHERE id = 'NOTE-...';"` |

### JSON Mode Example

```bash
# Enable JSON output and query
sqlite3 /path/to/mydata.db <<'SQL'
.mode json
SELECT id, title, tags FROM notes LIMIT 5;
SQL
```

Then pipe to `jq` for filtering or transformation:

```bash
sqlite3 /path/to/mydata.db "SELECT ..." | jq -r '.[] | select(.status == "active") | .id'
```

## Core Operations

### Initialize a Database

Create the database directory and initialize tables with constraints and pragmas:

```bash
# Create directory
mkdir -p /path/to/.sqlite

# Initialize database with pragmas and schema
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

**Prefix conventions:**
- Notes: `NOTE-`
- Tasks: `TASK-`
- Resources: `RES-`
- Clippings: `CLIP-`
- Breadcrumbs: `CRUMB-`
- Reflections: `REFL-`

### Create Records

Insert records with inline ID generation:

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
# Simple query with filtering and ordering
sqlite3 -header -column /path/to/.sqlite/mydata.db <<'SQL'
SELECT id, title, status, created_at
FROM notes
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT 10;
SQL
```

**Pagination example:**

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

Use `-line` mode for human-readable single-record display:

```bash
sqlite3 -line /path/to/.sqlite/mydata.db <<'SQL'
SELECT * FROM notes WHERE id = 'NOTE-20260208-a3f8c291';
SQL
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

```bash
sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
UPDATE notes
SET
  status = 'archived',
  updated_at = datetime('now')
WHERE id = 'NOTE-20260208-a3f8c291';
SQL
```

**Batch update example:**

```sql
UPDATE notes
SET status = 'archived', updated_at = datetime('now')
WHERE created_at < date('now', '-1 year');
```

### Delete Records

```bash
sqlite3 /path/to/.sqlite/mydata.db <<'SQL'
DELETE FROM notes WHERE id = 'NOTE-20260208-a3f8c291';
SQL
```

## Relationships

SQLite supports two relationship styles, each with distinct use cases.

### Structural Relationships (Foreign Key Columns)

Use foreign key columns for parent-child ownership and 1:1 or N:1 relationships:

```sql
CREATE TABLE clippings (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  resource_id TEXT,  -- Foreign key to resources table
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

Views are more powerful than memhub's saved queries — they can use joins, aggregations, and reference other views.

### Create a View

```sql
CREATE VIEW active_notes AS
SELECT id, title, status, created_at
FROM notes
WHERE status = 'active'
ORDER BY created_at DESC;
```

### Query a View

```sql
SELECT * FROM active_notes LIMIT 10;
```

### List All Views

```sql
SELECT name FROM sqlite_master WHERE type = 'view';
```

### Drop a View

```sql
DROP VIEW IF EXISTS active_notes;
```

### Complex View Example

```sql
-- Note graph view with link counts
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

Triggers automate repetitive tasks like timestamp updates and FTS synchronization.

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

See "Full-Text Search" section below for complete examples.

## Full-Text Search (FTS5)

SQLite's FTS5 extension provides ranked full-text search. Memhub cannot do this.

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

Keep the FTS index synchronized with the base table:

```sql
-- Trigger: insert
CREATE TRIGGER notes_fts_insert AFTER INSERT ON notes BEGIN
  INSERT INTO notes_fts(rowid, id, title, body, tags)
  VALUES (NEW.rowid, NEW.id, NEW.title, NEW.body, NEW.tags);
END;

-- Trigger: update
CREATE TRIGGER notes_fts_update AFTER UPDATE ON notes BEGIN
  UPDATE notes_fts
  SET title = NEW.title, body = NEW.body, tags = NEW.tags
  WHERE rowid = OLD.rowid;
END;

-- Trigger: delete
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

SQLite provides robust JSON support for array and object fields.

### Creating JSON Arrays

```sql
-- Inline array
INSERT INTO notes (id, title, tags)
VALUES (
  'NOTE-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Example Note',
  json_array('tag1', 'tag2', 'tag3')
);
```

### Querying JSON Arrays

```sql
-- Check if array contains a value
SELECT id, title
FROM notes
WHERE EXISTS (
  SELECT 1 FROM json_each(notes.tags)
  WHERE json_each.value = 'systems'
);

-- Count array elements
SELECT id, title, json_array_length(tags) AS tag_count
FROM notes
WHERE json_array_length(tags) > 3;

-- Extract unique tags across all notes
SELECT DISTINCT json_each.value AS tag
FROM notes, json_each(notes.tags)
WHERE notes.status = 'active'
ORDER BY tag;

-- Tag cloud (aggregation)
SELECT
  json_each.value AS tag,
  COUNT(*) AS note_count
FROM notes, json_each(notes.tags)
GROUP BY json_each.value
ORDER BY note_count DESC;
```

### Updating JSON Arrays

```sql
-- Add a tag (append to array)
UPDATE notes
SET tags = json_insert(tags, '$[#]', 'new-tag')
WHERE id = 'NOTE-20260208-a3f8c291';

-- Remove a tag (requires rebuilding array)
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

CHECK constraints replace YAML enum and pattern validation.

### Enum-Style Constraints

```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'archived')) DEFAULT 'draft',
  epistemic TEXT CHECK (epistemic IN ('hypothesis', 'tested', 'validated', 'outdated'))
);
```

### Range Constraints

```sql
CREATE TABLE resources (
  id TEXT PRIMARY KEY,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);
```

### Pattern Constraints (Regex)

SQLite doesn't have native regex in CHECK constraints, but you can validate formats:

```sql
CREATE TABLE resources (
  id TEXT PRIMARY KEY,
  url TEXT CHECK (url LIKE 'http%')
);
```

For complex validation, use application-level checks before INSERT.

## Aggregations

SQLite supports GROUP BY, COUNT, SUM, AVG, MIN, MAX, and more. Memhub cannot do this.

### Basic Aggregations

```sql
-- Notes per status
SELECT status, COUNT(*) AS count
FROM notes
GROUP BY status;

-- Average rating per resource type
SELECT resource_type, AVG(rating) AS avg_rating
FROM resources
WHERE rating IS NOT NULL
GROUP BY resource_type;

-- Monthly note creation counts
SELECT
  strftime('%Y-%m', created_at) AS month,
  COUNT(*) AS note_count
FROM notes
GROUP BY month
ORDER BY month DESC;
```

### Advanced Aggregations

```sql
-- Tag cloud with percentages
WITH tag_counts AS (
  SELECT
    json_each.value AS tag,
    COUNT(*) AS count
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

Specialized sqlite-db skills follow a consistent structure. They teach agents how to manage a specific domain using SQLite.

### Directory Layout

```
skills/sqlite-<domain>/
├── SKILL.md                # Skill instructions (when to use, workflows, SQL examples)
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

1. **Tables** — DDL for all domain entities with constraints, indexes, and foreign keys
2. **Indexes** — B-tree indexes for common queries, FTS indexes for search
3. **FTS** — Virtual tables and sync triggers for full-text search
4. **Views** — Saved queries as first-class database objects
5. **Triggers** — Auto-timestamps, FTS sync, validation
6. **Links vocabulary** — Named relationship types (same as memhub: `linksTo`, `derivedFrom`, `partOf`, etc.)
7. **Database path** — Where the `.db` file lives (e.g., `.sqlite/notes.db`)
8. **ID prefixes** — Conventions for generating human-readable IDs
9. **Workflows** — Step-by-step SQL examples for common tasks

### Design Principles

**Schemas encode domain knowledge.** The DDL is the documentation. Use meaningful column names, CHECK constraints, foreign keys, and indexes. The schema should tell you what's important.

**Target database explicitly.** Every `sqlite3` command should specify the full path to the database. Stateless invocation only.

**Views are your menu.** Create views for common queries. Views compose — they can reference other views, use joins, and include aggregations. They're more powerful than memhub's saved queries.

**Use both relationship styles.** Structural foreign keys for ownership (clipping→resource), flexible links table for ad-hoc graph relationships (note→note).

**Include setup scripts.** Provide an idempotent `setup.sh` that creates the database, runs the DDL, and initializes views. Users should be able to initialize a working database with one command.

**Show real workflows.** Don't just list SQL patterns — show the full flow of creating records, linking them, querying, updating, and analyzing over time.

**Be honest about tradeoffs.** SQL is verbose. String escaping is hazardous. But the power (JOINs, FTS, aggregations, window functions) makes it worthwhile for certain domains.
