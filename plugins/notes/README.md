# Notes Plugin

Personal knowledge management via SQLite. Capture thoughts, track reading, generate AI thinking trails, and synthesize insights—all in a single portable database.

## Overview

This plugin provides a complete note-taking system using SQLite as the storage layer. No server, no sync service, no proprietary format—just a `.db` file you own.

**Core capabilities:**
- Quick capture of fleeting thoughts to inbox
- Breadcrumb snapshots of your thinking state over time
- Resource tracking (articles, books, papers, videos)
- Clippings/highlights from resources
- AI-generated reflections and synthesis
- Full-text search with ranking
- Flexible linking between any entities

## Quick Start

```bash
# Initialize the database
cd /path/to/your/notes/
./plugins/notes/skills/sqlite-notes/scripts/setup.sh

# Capture a thought
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, body, folder, origin, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Your thought here...',
  'inbox',
  'me',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# See what's in your inbox
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"
```

## Commands

### `/quick-capture`

Ingest loose notes into the database. Analyzes input to chunk into distinct ideas (index cards, not post-its), proposes the breakdown for confirmation, then creates notes in the inbox.

```
/quick-capture Here's a stream of thoughts about distributed systems...
```

### `/crumb`

Generate a breadcrumb—an AI snapshot of your current thinking state. Analyzes recent notes, identifies themes and connections, surfaces open questions, and tracks intellectual momentum (exploring, converging, scattered, dormant, breakthrough).

```
/crumb article refinement session
```

### `/recent`

Get oriented with a headspace briefing. Reviews recent notes, breadcrumbs, reflections, and resources to show where you've been and suggest entry points for continuing work.

```
/recent
/recent week
/recent creative-practice
```

## Skills

### sqlite-notes

The core skill defining the notes domain: schema, views, workflows, and SQL patterns. Covers:

- **Notes**: Fleeting captures → working notes → permanent reference
- **Breadcrumbs**: Periodic AI thinking snapshots with theme/connection/question tracking
- **Resources**: Reading queue with status workflow (queued → reading → finished)
- **Clippings**: Highlights from resources with annotations
- **Reflections**: AI synthesis that can be promoted to permanent notes
- **Links**: Flexible many-to-many relationships between any entities

### sqlite-db

Foundation skill for SQLite database patterns. Use this when building new sqlite-based skills or understanding the underlying patterns.

## Database Location

The database lives at `.sqlite/notes.db` relative to your project root. The setup script creates this directory if needed.

## Key Concepts

### Folders (Note Workflow)

| Folder | Purpose |
|--------|---------|
| `inbox` | Unsorted, recently captured |
| `journal` | Date-bound entries |
| `working` | Active development |
| `permanent` | Evergreen, reference-quality |
| `archive` | Preserved but inactive |

### Provenance (Origin)

Every piece of content tracks who created it:
- `me` — You authored it
- `llm` — AI generated it entirely
- `external` — Imported from elsewhere
- `llm-assisted` — Collaborative human+AI creation

### Epistemic Status

How validated is this content?
- `fleeting` — Uncaptured intuition, might be nothing
- `developing` — Actively exploring, not concluded
- `supported` — Has backing evidence/reasoning
- `settled` — Firm belief, integrated into worldview

### Momentum (Breadcrumbs)

Breadcrumbs track intellectual momentum:
- `exploring` — Divergent, opening new territory
- `converging` — Ideas crystallizing toward clarity
- `scattered` — Multiple threads, not yet unified
- `dormant` — Consolidation period, not much movement
- `breakthrough` — Major insight or synthesis achieved

## Common Queries

```bash
# Inbox notes
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"

# Full-text search
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT n.id, n.title, snippet(notes_fts, 1, '**', '**', '...', 30) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'your search term'
ORDER BY rank;
SQL

# Notes by tag
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, tags FROM notes
WHERE EXISTS (SELECT 1 FROM json_each(tags) WHERE value = 'your-tag');
SQL

# Tag cloud
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_tag_cloud LIMIT 20;"

# Latest breadcrumb
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_latest_breadcrumb;"

# Breadcrumb trail
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, momentum, substr(summary, 1, 60) AS summary_preview, generated_at
FROM breadcrumbs
ORDER BY generated_at DESC
LIMIT 10;
SQL

# Reading queue
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_reading_queue;"

# Monthly activity
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_monthly_activity;"
```

## Pre-defined Views

The schema includes views for common access patterns:

| View | Description |
|------|-------------|
| `v_inbox` | Notes in inbox folder |
| `v_working` | Notes being actively developed |
| `v_evergreen` | Permanent/reference notes |
| `v_stale_working` | Working notes not reviewed in 30+ days |
| `v_reading_queue` | Resources queued for reading |
| `v_currently_reading` | Resources being actively read |
| `v_latest_breadcrumb` | Most recent breadcrumb |
| `v_draft_reflections` | Reflections awaiting review |
| `v_tag_cloud` | Tag usage statistics |
| `v_monthly_activity` | Note counts by month and folder |
| `v_resource_stats` | Resource counts by type and status |
| `v_note_graph` | Bidirectional note relationships |
| `v_note_richness` | Notes ranked by connectivity |

## Philosophy

**Capture-heavy, not pristine.** Get ideas out of your head with minimal friction. Organize during weekly review, not during capture.

**Story over structure.** Capture how you ended up thinking the way you do. Notes evolve. Breadcrumbs snapshot moments. Reflections synthesize patterns.

**Clear provenance.** Always know what came from where. Trace any idea back to its source.

**SQL is the interface.** No wrapper, no abstraction. You get the full power of SQLite: JOINs, FTS5, window functions, CTEs, aggregations.

## Files

```
plugins/notes/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── commands/
│   ├── quick-capture.md      # Note ingestion command
│   ├── crumb.md              # Breadcrumb generation command
│   └── recent.md             # Headspace briefing command
├── skills/
│   ├── sqlite-db/
│   │   └── SKILL.md          # Foundation SQLite patterns
│   └── sqlite-notes/
│       ├── SKILL.md          # Notes domain skill
│       ├── assets/
│       │   ├── schema.sql    # Tables, indexes, FTS, triggers
│       │   └── views.sql     # Pre-defined views
│       ├── scripts/
│       │   ├── setup.sh      # Database initialization
│       │   └── examples.sh   # Demo workflows
│       └── references/
│           └── queries.md    # Advanced query recipes
└── README.md                 # This file
```

## License

CC-BY-SA-4.0
