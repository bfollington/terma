---
name: sqlite-notes
description: Personal note-taking, thinking trails, and knowledge management using plain SQLite. Supports capture-heavy workflows with clear provenance tracking, AI-generated thinking snapshots (breadcrumbs), and synthesis into permanent knowledge. Uses the sqlite3 CLI directly with SQL schemas for notes, resources, clippings, reflections, and breadcrumbs.
---

# SQLite Notes - Personal Thinking Environment

**A minimalist sqlite skill for note-taking, thinking trails, and knowledge building.**

This skill uses SQLite as a local-first, composable thinking environment that captures the story of how you ended up thinking the way you do, with full lineage and provenance tracking. SQL is the interface, schemas are DDL, and the database is portable.

## Overview

**sqlite-notes** transforms SQLite into a personal knowledge system that:
- Captures notes, resources, clippings, and reflections with clear provenance
- Generates AI thinking trail snapshots (breadcrumbs) to track intellectual momentum
- Organizes notes through workflow stages (inbox, working, permanent, archive)
- Links entities naturally through a flexible links table and structural foreign keys
- Synthesizes insights from multiple sources with full lineage tracking
- Provides full-text search with FTS5 (ranking, boolean operators, snippets)
- Keeps all data local in a single `.sqlite/notes.db` file
- Works seamlessly with Claude Code for AI-assisted thinking and synthesis

## Philosophy

### Capture-Heavy, Not Pristine

This system prioritizes capturing the raw materials of thinking over maintaining a perfectly organized knowledge graph. Notes are allowed to be messy, incomplete, and evolving. The goal is to preserve the trail of how ideas developed, not to present a polished final product.

### Story Over Structure

Rather than forcing everything into a predetermined taxonomy, this system captures the story of how you ended up thinking the way you do. Notes evolve from fleeting captures to permanent references. Breadcrumbs snapshot your thinking at a moment in time. Reflections synthesize patterns that emerge.

### Clear Provenance

Every piece of content explicitly tracks its origin:
- **me**: You authored it
- **llm**: AI generated it entirely
- **external**: Imported from elsewhere
- **llm-assisted**: Collaborative creation between you and AI

This transparency ensures you always know what came from where, and can trace the lineage of any idea.

### Epistemic Status

Separate from *who* created content is *how validated* it is. The `epistemic` field tracks confidence:

| Status | Meaning |
|--------|---------|
| **fleeting** | Uncaptured intuition, shower thought, might be nothing |
| **developing** | Actively thinking about, exploring, not concluded |
| **supported** | Has backing - evidence, reasoning, sources |
| **settled** | Firm belief, integrated into worldview, acting on it |

This applies equally to human and AI content. A shower thought (`origin: me, epistemic: fleeting`) and a Claude synthesis (`origin: llm, epistemic: fleeting`) both start unvalidated. Through review, either can become `supported` or `settled`.

This enables workflows like syntopic reading where Claude explores sources and generates speculative connections. Those start as `fleeting`, get upgraded to `supported` when evidence backs them, and to `settled` when you've reviewed and accepted them into your thinking.

### AI as Thinking Partner

Breadcrumbs and reflections leverage AI to:
- Surface patterns you might miss
- Connect ideas across time
- Ask questions that push thinking forward
- Synthesize insights from scattered notes

But they preserve full context - the prompts used, the notes considered, the relationships formed - so you can verify and understand the AI's reasoning.

## When to Use This Skill

**Use sqlite-notes as your memory-on-disk for thinking.** This skill is relevant whenever you need to:

### Capture & Organize Thoughts
- Quick capture of fleeting ideas without friction
- Save interesting quotes and highlights from reading
- Track external resources (articles, papers, videos, repos)
- Organize notes through workflow stages as they mature

### Track Thinking Over Time
- Generate breadcrumb snapshots of current intellectual state
- See what themes are emerging in your notes
- Identify momentum (exploring, converging, scattered, breakthrough)
- Maintain continuity between thinking sessions

### Synthesize Knowledge
- Generate AI reflections from notes, breadcrumbs, and clippings
- Promote valuable reflections into permanent notes
- Build evergreen notes from accumulated insights
- Trace lineage from source material to synthesized knowledge

### Link Ideas
- Connect notes through explicit relationships in the links table
- Query relationships between notes, resources, and clippings with JOINs
- Discover unexpected patterns through graph traversal queries
- Leverage SQL to find multi-hop connections

### Review & Process
- Weekly review of inbox notes
- Move notes between workflow stages
- Tag and categorize during review
- Identify stale working notes

### Replace Scattered Notes
Instead of maintaining notes in:
- Scattered markdown files
- Ephemeral chat messages
- Bookmarks that never get read
- Mental notes that get forgotten

Keep everything in one queryable, linkable, persistent database with full-text search.

## Core Tables

### notes
The atomic unit of thought. Can be anything from a fleeting idea to a permanent reference note.

**Key fields:** `id`, `title`, `body`, `folder`, `origin`, `epistemic`, `tags` (JSON array), `source_url`, `source_title`, `captured_at`, `reviewed_at`

**Workflow stages (folder):**
- **inbox**: Unsorted, recently captured
- **journal**: Date-bound entries
- **working**: Active development, exploring ideas
- **permanent**: Evergreen, reference-quality
- **archive**: Preserved but no longer active

**Provenance (origin):** me, llm, external, llm-assisted

**Epistemic status:** fleeting, developing, supported, settled

### breadcrumbs
AI-generated snapshot of your thinking state at a moment in time. Analyzes recent notes to surface themes, connections, questions, and momentum. Forms a continuous trail over time through the `prev_breadcrumb_id` foreign key.

**Key fields:** `id`, `summary`, `themes` (JSON array), `connections`, `questions` (JSON array), `momentum`, `window_start`, `window_end`, `notes_considered`, `prev_breadcrumb_id` (FK to breadcrumbs)

**Momentum states:** exploring, converging, scattered, dormant, breakthrough

### resources
External reference material (articles, books, papers, videos, repos, etc.) that you want to track and potentially extract highlights from.

**Key fields:** `id`, `url`, `title`, `resource_type`, `status`, `author`, `domain`, `rating`, `summary`, `tags` (JSON array), `added_at`, `finished_at`

**Resource types:** article, book, paper, video, podcast, repo, tool, course, thread, other

**Status workflow:** queued → reading → finished (or abandoned/reference)

### clippings
Quote, highlight, or excerpt from a resource. Captures exact text along with location and personal annotations. Uses `resource_id` foreign key for structural relationship (no separate link needed).

**Key fields:** `id`, `content`, `annotation`, `location`, `chapter`, `source`, `resource_id` (FK to resources), `external_id`, `tags` (JSON array), `clipped_at`

**Sources:** readwise, kindle, manual, web, pdf, other

### reflections
AI-generated synthesis of notes, breadcrumbs, and clippings. Can be weekly reviews, theme explorations, connection maps, or custom formats. Tracks full generation context and can be promoted to permanent notes via `promoted_to_note_id` FK.

**Key fields:** `id`, `title`, `content`, `reflection_type`, `template_used`, `prompt_context`, `model`, `status`, `epistemic`, `rating`, `feedback`, `promoted_to_note_id` (FK to notes), `generated_at`

**Reflection types:** weekly-review, theme-synthesis, question-exploration, connection-map, insight, custom

**Status workflow:** draft → reviewed → promoted (or discarded)

### links
Generic relationship table for flexible many-to-many connections between any entities. This is the graph table.

**Key fields:** `source_id`, `target_id`, `rel_type`

**Relationship vocabulary:**
- **linksTo**: Conceptual connection (note → note)
- **derivedFrom**: Evolution/refinement (note → note)
- **references**: External source citation (note → resource)
- **includesClipping**: Embedded quote (note → clipping)
- **promptedBy**: AI-inspired (note → breadcrumb)
- **continuesFrom**: Trail continuation (breadcrumb → breadcrumb, via FK but can also be in links)
- **analyzedNotes**: Input for AI analysis (breadcrumb → note)
- **suggestedConnections**: AI recommendation (breadcrumb → note)
- **mentionedIn**: Reverse reference (resource → note)
- **relatedTo**: Conceptual similarity (resource → resource)
- **usedIn**: Quote usage (clipping → note)
- **promptedReflection**: Synthesis inspiration (clipping → reflection)
- **basedOnBreadcrumbs**: Synthesis input (reflection → breadcrumb)
- **basedOnNotes**: Synthesis input (reflection → note)
- **basedOnClippings**: Synthesis input (reflection → clipping)
- **promotedTo**: Became permanent (reflection → note, via FK but can also be in links)
- **followsUp**: Sequential reflection (reflection → reflection)

## Setup

### One-Command Setup

```bash
# Initialize database with schema and views
cd /path/to/your/notes/
./skills/sqlite-notes/scripts/setup.sh
```

This creates `.sqlite/notes.db` with all tables, indexes, FTS virtual tables, triggers, and views.

### Manual Setup

```bash
# Create database directory
mkdir -p .sqlite

# Apply schema
sqlite3 .sqlite/notes.db < skills/sqlite-notes/assets/schema.sql

# Apply views
sqlite3 .sqlite/notes.db < skills/sqlite-notes/assets/views.sql

# Verify
sqlite3 .sqlite/notes.db "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
```

## Workflow Patterns

### Quick Capture Flow

**Goal:** Get thoughts out of your head with minimal friction.

```bash
# Capture a fleeting thought
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, body, folder, origin, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Interesting thought about distributed consensus...',
  'inbox',
  'me',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# Capture with title and tags
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, title, body, folder, origin, tags, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Meeting notes - Product sync',
  'Key decisions:
- Ship v2 next month
- Focus on performance',
  'journal',
  'me',
  json_array('meetings', 'product'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# Capture from external source
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, title, body, folder, origin, source_url, source_title, tags, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Notes from Lamport paper',
  'Key insight: [[N-a8f9B3c2]] relates to this',
  'inbox',
  'external',
  'https://example.com/paper.pdf',
  'Time, Clocks, and the Ordering of Events',
  json_array('distributed-systems'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL
```

### Weekly Review Flow

**Goal:** Process inbox, move notes to appropriate folders, add links and tags.

```bash
# 1. Check what's in inbox (use view for quick access)
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"

# 2. Review a specific note
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM notes WHERE id = 'N-20260208-a8f9b3c2';"

# 3. Move to appropriate folder, add tags, mark as reviewed
sqlite3 .sqlite/notes.db <<'SQL'
UPDATE notes
SET folder = 'working',
    tags = json_array('distributed-systems', 'consensus'),
    reviewed_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
WHERE id = 'N-20260208-a8f9b3c2';
SQL

# 4. Add connections to related notes
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO links (source_id, target_id, rel_type)
VALUES ('N-20260208-a8f9b3c2', 'N-20260205-x7y8z9w0', 'linksTo');
SQL

# 5. Check for stale working notes
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_stale_working;"

# 6. Promote mature note to permanent
sqlite3 .sqlite/notes.db <<'SQL'
UPDATE notes
SET folder = 'permanent',
    epistemic = 'supported',
    reviewed_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
WHERE id = 'N-20260208-a8f9b3c2';
SQL
```

### Breadcrumb Generation Flow

**Goal:** Generate AI snapshot of current thinking state.

```bash
# 1. Query recent notes as JSON for AI analysis (last 7 days in inbox + working)
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, body, folder, tags, captured_at
FROM notes
WHERE (folder IN ('inbox', 'working'))
  AND captured_at >= date('now', '-7 days')
ORDER BY captured_at DESC;
SQL

# 2. Get previous breadcrumb for continuity
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT * FROM v_latest_breadcrumb;
SQL

# 3. AI analyzes the notes and generates:
#    - summary: high-level state
#    - themes: emerging topics
#    - connections: patterns noticed
#    - questions: things to explore
#    - momentum: exploring/converging/scattered/dormant/breakthrough

# 4. Create the breadcrumb
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO breadcrumbs (
  id, summary, themes, connections, questions, momentum,
  window_start, window_end, notes_considered, prev_breadcrumb_id, generated_at
)
VALUES (
  'BC-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Exploring connections between distributed systems and product design',
  json_array('distributed-systems', 'product-design', 'team-dynamics'),
  'Conways law appearing in both architecture and feature discussions',
  json_array('How does team structure affect API design?', 'What patterns cross domains?'),
  'exploring',
  strftime('%Y-%m-%dT%H:%M:%SZ', date('now', '-7 days')),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now'),
  15,
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# 5. Batch link breadcrumb to all analyzed notes
# This is where SQL shines — one query creates N links
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  (SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1),
  notes.id,
  'analyzedNotes'
FROM notes
WHERE (folder IN ('inbox', 'working'))
  AND captured_at >= date('now', '-7 days');
SQL
```

### Reflection Generation and Promotion

**Goal:** Generate AI synthesis and promote valuable insights to permanent notes.

```bash
# 1. Generate reflection from notes and breadcrumbs
# (AI analyzes input and generates title + content)

# 2. Create the reflection
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO reflections (
  id, title, content, reflection_type, model, status, epistemic, generated_at
)
VALUES (
  'RF-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Weekly Review: Design Patterns',
  '# Key Insights

This week showed strong convergence around distributed systems patterns...

## Main Themes
- Conway''s Law in practice
- API design as team communication
- Emergent architecture

## Questions to Explore
- How to design for team evolution?',
  'weekly-review',
  'claude-sonnet-4-5-20250929',
  'draft',
  'fleeting',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# 3. Batch link to source material (notes and breadcrumbs that informed it)
sqlite3 .sqlite/notes.db <<'SQL'
-- Link to recent breadcrumbs
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  (SELECT id FROM reflections ORDER BY generated_at DESC LIMIT 1),
  bc.id,
  'basedOnBreadcrumbs'
FROM breadcrumbs bc
WHERE bc.generated_at >= date('now', '-14 days')
LIMIT 3;

-- Link to notes analyzed
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  (SELECT id FROM reflections ORDER BY generated_at DESC LIMIT 1),
  n.id,
  'basedOnNotes'
FROM notes n
WHERE n.folder IN ('working', 'permanent')
  AND EXISTS (
    SELECT 1 FROM json_each(n.tags)
    WHERE value IN ('distributed-systems', 'product-design')
  );
SQL

# 4. Review and rate the reflection
sqlite3 .sqlite/notes.db <<'SQL'
UPDATE reflections
SET status = 'reviewed',
    rating = 4,
    feedback = 'Good synthesis, helped clarify thinking on Conway''s Law'
WHERE id = 'RF-20260208-a1b2c3d4';
SQL

# 5. Promote valuable reflection to permanent note
sqlite3 .sqlite/notes.db <<'SQL'
-- Create the permanent note
INSERT INTO notes (id, title, body, folder, origin, epistemic, tags, captured_at)
SELECT
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  title,
  content,
  'permanent',
  'llm-assisted',
  'supported',
  json_array('distributed-systems', 'design-patterns'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
FROM reflections
WHERE id = 'RF-20260208-a1b2c3d4';

-- Update reflection with promoted_to_note_id and status
UPDATE reflections
SET promoted_to_note_id = (
      SELECT id FROM notes WHERE title = 'Weekly Review: Design Patterns' ORDER BY captured_at DESC LIMIT 1
    ),
    status = 'promoted'
WHERE id = 'RF-20260208-a1b2c3d4';
SQL
```

### Resource and Clipping Flow

**Goal:** Track external resources and extract valuable highlights.

```bash
# 1. Add resource to reading queue
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO resources (id, url, title, resource_type, author, status, tags, added_at)
VALUES (
  'R-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'https://example.com/article',
  'How to Build Better Software',
  'article',
  'Jane Smith',
  'queued',
  json_array('software-engineering', 'process'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# 2. Start reading
sqlite3 .sqlite/notes.db <<'SQL'
UPDATE resources
SET status = 'reading'
WHERE id = 'R-20260208-x7k9m2n5';
SQL

# 3. Capture clipping from resource
# Note: resource_id FK creates structural relationship — no separate link needed
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO clippings (id, content, annotation, location, source, resource_id, tags, clipped_at)
VALUES (
  'CL-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'The best code is no code at all.',
  'This resonates with minimalism in design',
  'p. 42',
  'manual',
  'R-20260208-x7k9m2n5',
  json_array('minimalism'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL

# 4. Use clipping in a note
sqlite3 .sqlite/notes.db <<'SQL'
-- Create note that references the clipping
INSERT INTO notes (id, body, folder, origin, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  '> The best code is no code at all.

This connects to minimalism principles in architecture design.',
  'working',
  'me',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);

-- Link note to clipping
INSERT INTO links (source_id, target_id, rel_type)
VALUES (
  (SELECT id FROM notes ORDER BY captured_at DESC LIMIT 1),
  'CL-20260208-a1b2c3d4',
  'includesClipping'
);
SQL

# 5. Finish resource with rating
sqlite3 .sqlite/notes.db <<'SQL'
UPDATE resources
SET status = 'finished',
    rating = 4,
    summary = 'Good overview of software minimalism principles',
    finished_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
WHERE id = 'R-20260208-x7k9m2n5';
SQL
```

## Full-Text Search

FTS5 provides powerful full-text search capabilities that memhub doesn't have.

```bash
# Basic full-text search on notes
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT n.id, n.title, snippet(notes_fts, 1, '**', '**', '...', 20) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'distributed AND systems'
ORDER BY rank;
SQL

# Boolean operators
sqlite3 .sqlite/notes.db <<'SQL'
-- AND: both terms must appear
SELECT id, title FROM notes WHERE rowid IN (
  SELECT rowid FROM notes_fts WHERE notes_fts MATCH 'distributed AND consensus'
);

-- OR: either term
SELECT id, title FROM notes WHERE rowid IN (
  SELECT rowid FROM notes_fts WHERE notes_fts MATCH 'distributed OR consensus'
);

-- NOT: exclude term
SELECT id, title FROM notes WHERE rowid IN (
  SELECT rowid FROM notes_fts WHERE notes_fts MATCH 'distributed NOT systems'
);

-- Phrase search
SELECT id, title FROM notes WHERE rowid IN (
  SELECT rowid FROM notes_fts WHERE notes_fts MATCH '"distributed systems"'
);
SQL

# Search with ranking and snippets
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  n.id,
  n.title,
  snippet(notes_fts, 1, '>>>', '<<<', '...', 30) AS match_context,
  bm25(notes_fts) AS relevance_score
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'consensus'
ORDER BY bm25(notes_fts)
LIMIT 10;
SQL

# Search clippings
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  c.id,
  c.content,
  snippet(clippings_fts, 0, '**', '**', '...', 40) AS snippet
FROM clippings_fts
JOIN clippings c ON clippings_fts.rowid = c.rowid
WHERE clippings_fts MATCH 'minimalism'
ORDER BY rank;
SQL

# Search reflections
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  r.id,
  r.title,
  snippet(reflections_fts, 1, '**', '**', '...', 50) AS snippet
FROM reflections_fts
JOIN reflections r ON reflections_fts.rowid = r.rowid
WHERE reflections_fts MATCH 'design patterns'
ORDER BY rank;
SQL
```

## Views (Saved Queries)

Views are pre-defined queries that you can reference like tables. They simplify common access patterns.

```bash
# Use views for common queries
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_working;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_evergreen;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_stale_working;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_reading_queue;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_currently_reading;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_latest_breadcrumb;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_draft_reflections;"

# Analytics views
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_tag_cloud LIMIT 20;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_monthly_activity;"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_resource_stats;"

# Graph views
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_note_graph WHERE center_id = 'N-20260208-a1b2';"
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_note_richness LIMIT 10;"

# Views compose — you can join them or filter them
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT i.*, (SELECT COUNT(*) FROM links WHERE source_id = i.id) AS link_count
FROM v_inbox i
WHERE EXISTS (SELECT 1 FROM json_each(i.tags) WHERE value = 'distributed-systems')
ORDER BY link_count DESC;
SQL
```

## Queries That Are Better in SQL

These queries showcase SQL's advantages over a key-value store with CLI abstractions.

### JOINs: Clippings from Highly-Rated Resources

```bash
# One query, leveraging FK and JOIN
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  c.id AS clipping_id,
  c.content,
  c.annotation,
  r.title AS resource_title,
  r.rating
FROM clippings c
JOIN resources r ON c.resource_id = r.id
WHERE r.rating >= 4
ORDER BY r.rating DESC, c.clipped_at DESC;
SQL
```

In memhub, this would require: query all clippings → extract resource IDs → query each resource → filter by rating → combine results in jq.

### Aggregations: Notes Per Folder Per Origin

```bash
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  folder,
  origin,
  COUNT(*) AS note_count,
  COUNT(CASE WHEN epistemic = 'settled' THEN 1 END) AS settled_count
FROM notes
GROUP BY folder, origin
ORDER BY folder, origin;
SQL
```

Memhub can't aggregate in-database. You'd need to query all notes, then aggregate in jq or scripts.

### Window Functions: Breadcrumb Momentum Trend

```bash
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  id,
  summary,
  momentum,
  generated_at,
  LAG(momentum) OVER (ORDER BY generated_at) AS prev_momentum,
  CASE
    WHEN momentum = 'breakthrough' THEN '!'
    WHEN momentum = LAG(momentum) OVER (ORDER BY generated_at) THEN '→'
    ELSE '↗'
  END AS trend
FROM breadcrumbs
ORDER BY generated_at DESC;
SQL
```

This shows momentum changes over time. Impossible in memhub without exporting data and processing externally.

### CTEs: Full Lineage of a Promoted Reflection

```bash
sqlite3 -header -column .sqlite/notes.db <<'SQL'
WITH RECURSIVE lineage AS (
  -- Start with the promoted note
  SELECT id, title, 'promoted_note' AS entity_type, 0 AS depth
  FROM notes
  WHERE id = 'N-20260208-final'

  UNION ALL

  -- Traverse backwards through links
  SELECT
    CASE
      WHEN l.source_id LIKE 'RF-%' THEN l.source_id
      WHEN l.source_id LIKE 'BC-%' THEN l.source_id
      WHEN l.source_id LIKE 'N-%' THEN l.source_id
    END AS id,
    CASE
      WHEN l.source_id LIKE 'RF-%' THEN (SELECT title FROM reflections WHERE id = l.source_id)
      WHEN l.source_id LIKE 'BC-%' THEN (SELECT summary FROM breadcrumbs WHERE id = l.source_id)
      WHEN l.source_id LIKE 'N-%' THEN (SELECT title FROM notes WHERE id = l.source_id)
    END AS title,
    CASE
      WHEN l.source_id LIKE 'RF-%' THEN 'reflection'
      WHEN l.source_id LIKE 'BC-%' THEN 'breadcrumb'
      WHEN l.source_id LIKE 'N-%' THEN 'note'
    END AS entity_type,
    lineage.depth + 1
  FROM lineage
  JOIN links l ON lineage.id = l.target_id
  WHERE lineage.depth < 5
)
SELECT * FROM lineage ORDER BY depth;
SQL
```

This traces the entire provenance chain. Memhub has basic relationship traversal but nothing like recursive CTEs.

### Cross-Entity Search: UNION ALL

```bash
# Search across all content types in one query
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT 'note' AS type, id, title, captured_at AS timestamp
FROM notes
WHERE body LIKE '%consensus%'

UNION ALL

SELECT 'clipping' AS type, id, NULL AS title, clipped_at AS timestamp
FROM clippings
WHERE content LIKE '%consensus%'

UNION ALL

SELECT 'reflection' AS type, id, title, generated_at AS timestamp
FROM reflections
WHERE content LIKE '%consensus%'

ORDER BY timestamp DESC;
SQL
```

## Common Queries

### Find Notes

```bash
# All inbox notes
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_inbox;"

# Recent captures (last 7 days)
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, folder, captured_at
FROM notes
WHERE captured_at >= date('now', '-7 days')
ORDER BY captured_at DESC;
SQL

# Notes with specific tag
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, tags
FROM notes
WHERE EXISTS (
  SELECT 1 FROM json_each(tags) WHERE value = 'distributed-systems'
);
SQL

# Evergreen notes
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_evergreen;"

# LLM-generated notes
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, origin, epistemic
FROM notes
WHERE origin IN ('llm', 'llm-assisted')
ORDER BY captured_at DESC;
SQL

# Stale working notes (not reviewed in 30 days)
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_stale_working;"

# Notes by origin breakdown
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT origin, COUNT(*) AS count
FROM notes
GROUP BY origin
ORDER BY count DESC;
SQL
```

### Find Resources

```bash
# Reading queue
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_reading_queue;"

# Currently reading
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_currently_reading;"

# Finished articles
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, author, rating, finished_at
FROM resources
WHERE resource_type = 'article' AND status = 'finished'
ORDER BY finished_at DESC;
SQL

# Highly rated resources
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, resource_type, rating, finished_at
FROM resources
WHERE rating >= 4
ORDER BY rating DESC, finished_at DESC;
SQL
```

### Find Breadcrumbs and Reflections

```bash
# Latest breadcrumb
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_latest_breadcrumb;"

# Breadcrumbs showing breakthrough momentum
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, summary, momentum, generated_at
FROM breadcrumbs
WHERE momentum = 'breakthrough'
ORDER BY generated_at DESC;
SQL

# Draft reflections needing review
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_draft_reflections;"

# Promoted reflections
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, reflection_type, rating, promoted_to_note_id
FROM reflections
WHERE status = 'promoted'
ORDER BY generated_at DESC;
SQL
```

### Provenance Queries

```bash
# Epistemic distribution
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT epistemic, COUNT(*) AS count
FROM notes
WHERE epistemic IS NOT NULL
GROUP BY epistemic
ORDER BY
  CASE epistemic
    WHEN 'fleeting' THEN 1
    WHEN 'developing' THEN 2
    WHEN 'supported' THEN 3
    WHEN 'settled' THEN 4
  END;
SQL

# Origin breakdown with epistemic cross-tab
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT
  origin,
  COUNT(*) AS total,
  COUNT(CASE WHEN epistemic = 'fleeting' THEN 1 END) AS fleeting,
  COUNT(CASE WHEN epistemic = 'supported' THEN 1 END) AS supported,
  COUNT(CASE WHEN epistemic = 'settled' THEN 1 END) AS settled
FROM notes
GROUP BY origin
ORDER BY total DESC;
SQL
```

## AI-Assisted Workflows with Claude Code

Claude Code should always use full paths to the database and heredoc style for multi-line SQL.

### Quick Note Capture

**User:** "Capture this thought: distributed systems are really about managing uncertainty"

**Claude Code:**

```bash
sqlite3 .sqlite/notes.db <<'SQL'
INSERT INTO notes (id, body, folder, origin, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Distributed systems are really about managing uncertainty',
  'inbox',
  'me',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
SQL
```

### Generate Breadcrumb

**User:** "/breadcrumb"

**Claude Code:**

1. Query recent notes as JSON for analysis
2. Fetch previous breadcrumb for context
3. Analyze themes, connections, momentum
4. INSERT new breadcrumb with prev_breadcrumb_id
5. Batch INSERT...SELECT into links for analyzedNotes relationships

### Synthesize Reflection

**User:** "Generate a weekly review reflection"

**Claude Code:**

1. Query notes from past week
2. Fetch recent breadcrumbs
3. Generate synthesis
4. INSERT reflection
5. Batch INSERT...SELECT into links for basedOnNotes and basedOnBreadcrumbs relationships

### Link Related Notes

**User:** "Find notes related to distributed systems and connect them"

**Claude Code:**

1. Query notes with relevant tags
2. Analyze content for conceptual connections
3. INSERT INTO links with linksTo relationships
4. Report on connections made

## Tips & Best Practices

1. **Capture First, Organize Later**: Get ideas out of your head immediately. Weekly review is when you organize.

2. **Trust the Folder Workflow**: inbox → working → permanent mirrors how ideas mature. Don't force notes into permanent prematurely.

3. **Use Origin Consistently**: Always set the correct origin (me/llm/external/llm-assisted) for provenance clarity.

4. **Generate Breadcrumbs Regularly**: Weekly breadcrumbs create continuity and surface patterns you might miss.

5. **Review Reflections**: Rate and give feedback on AI-generated reflections to improve future generations.

6. **Promote Selectively**: Only promote reflections that genuinely add value. Not every reflection needs to become a permanent note.

7. **Archive, Don't Delete**: Move old working notes to archive instead of deleting. Preserves thinking history.

8. **Full Lineage Always**: When creating reflections or derived notes, always link back to source material.

9. **Tag During Review**: Don't stress about tagging during capture. Add tags during weekly review when context is clearer.

10. **Leverage FTS5**: Use full-text search with boolean operators for discovery. It's faster and more powerful than LIKE.

11. **Use Views, Not Memorized Queries**: Views are pre-optimized and self-documenting. Reference them by name.

12. **JSON Output for Agent Processing**: Use `sqlite3 -json` when Claude Code needs to process results. It's already parsed.

13. **Human-Readable for Display**: Use `sqlite3 -header -column` for tabular output that humans read.

14. **Batch Link Creation**: Use `INSERT...SELECT` to create N links at once. SQL shines here.

15. **Trust CHECK Constraints**: Don't validate enums in the agent. The database enforces them. If an INSERT fails, the constraint message tells you why.

## Reference Files

This skill includes:

- **SKILL.md**: This document (philosophy, workflows, SQL patterns)
- **assets/schema.sql**: Complete DDL (tables, indexes, FTS, triggers)
- **assets/views.sql**: 13 pre-defined views for common queries
- **scripts/setup.sh**: One-command idempotent database initialization
- **scripts/examples.sh**: Workflow demonstration with sample data
- **references/queries.md**: Advanced query recipes (JOINs, CTEs, window functions)

## Comparison: SQLite vs Memhub

### Where SQLite Wins

- **Full-text search**: FTS5 with ranking, boolean operators, snippets. Memhub has nothing.
- **JOINs**: "Clippings from resources I rated 4+" is one query. Memhub needs N separate commands + jq.
- **Batch linking**: `INSERT INTO links ... SELECT ...` creates N links at once. Memhub needs N `memhub link` calls.
- **Aggregations**: Notes per folder per month, tag clouds, resource stats — all in-database.
- **Views compose**: A view can reference other views, use JOINs, subqueries.
- **Schema is self-documenting**: `.schema` shows everything. No separate YAML files.
- **Universal tool**: `sqlite3` is installed everywhere. No custom CLI to distribute.

### Where SQLite Loses

- **Verbosity**: INSERT with 8 columns is ~10 lines vs. `memhub create Note '{...}'`.
- **Array handling**: `EXISTS (SELECT 1 FROM json_each(tags) WHERE value = 'x')` vs. `tags contains "x"`.
- **No visualization**: No `--visualize` or `--format mermaid`.
- **Quoting hazards**: SQL string escaping (`Conway''s Law`) is error-prone for agents.
- **No YAML metadata**: Field descriptions/examples live in SKILL.md, not alongside the schema.
- **ID generation**: Must compose inline every INSERT: `'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4)))`.

### The Honest Assessment

SQLite is strictly more powerful (FTS, JOINs, aggregations), but memhub is more ergonomic for single-record CRUD and relationship traversal. The CLI abstraction reduces boilerplate. The YAML schemas are self-documenting.

If your workflows are read-heavy, query-heavy, and need search/aggregations, SQLite wins. If your workflows are write-heavy with lots of one-off record creation and simple relationship traversal, memhub's CLI is faster.

For an AI agent, both are viable. SQLite requires more care with quoting and multi-line SQL, but it rewards you with composable, powerful queries. Memhub is safer (no SQL injection risk from user input) but hits a ceiling when you need JOINs or FTS.

This skill exists to test the hypothesis: "Is memhub just a skill + a database?" The answer is nuanced. Memhub adds value through its CLI ergonomics and YAML-driven schema validation. But SQLite + a good skill can achieve the same outcomes with more power and flexibility.

---

**This skill demonstrates SQL-native personal knowledge management.**

For customization, modify the schema and views to fit your personal thinking and note-taking style. The goal is to capture how you think, not to force your thinking into a predefined structure.
