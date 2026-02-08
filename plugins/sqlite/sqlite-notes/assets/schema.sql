-- ============================================================================
-- SQLite Notes Schema
-- ============================================================================
-- This is the DDL for the notes domain — the SQL equivalent of the 5 YAML
-- concept schemas in the memhub-notes skill. All tables use IF NOT EXISTS
-- for idempotent initialization.
--
-- To apply this schema:
--   sqlite3 /path/to/notes.db < schema.sql
--
-- Or interactively:
--   sqlite3 /path/to/notes.db
--   .read schema.sql
-- ============================================================================

-- Performance and integrity settings
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ============================================================================
-- TABLE: notes
-- ============================================================================
-- Core note-taking entity: fleeting captures, working notes, permanent notes.
-- Uses folder-based organization and epistemic status tracking.
-- ============================================================================

CREATE TABLE IF NOT EXISTS notes (
    rowid INTEGER PRIMARY KEY,
    id TEXT UNIQUE NOT NULL,
    title TEXT,
    body TEXT NOT NULL,
    folder TEXT NOT NULL DEFAULT 'inbox' CHECK (folder IN ('inbox', 'journal', 'working', 'permanent', 'archive')),
    origin TEXT NOT NULL DEFAULT 'me' CHECK (origin IN ('me', 'llm', 'external', 'llm-assisted')),
    epistemic TEXT DEFAULT 'fleeting' CHECK (epistemic IS NULL OR epistemic IN ('fleeting', 'developing', 'supported', 'settled')),
    tags TEXT DEFAULT '[]' CHECK (json_valid(tags)),
    source_url TEXT,
    source_title TEXT,
    captured_at TEXT NOT NULL,
    reviewed_at TEXT,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_notes_folder ON notes(folder);
CREATE INDEX IF NOT EXISTS idx_notes_origin ON notes(origin);
CREATE INDEX IF NOT EXISTS idx_notes_captured_at ON notes(captured_at);
CREATE INDEX IF NOT EXISTS idx_notes_epistemic ON notes(epistemic);

-- Auto-update updated_at on UPDATE
CREATE TRIGGER IF NOT EXISTS trg_notes_updated_at
AFTER UPDATE ON notes
FOR EACH ROW
BEGIN
    UPDATE notes SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
    WHERE rowid = NEW.rowid;
END;

-- ============================================================================
-- TABLE: breadcrumbs
-- ============================================================================
-- Periodic synthesis of thinking patterns: themes, connections, momentum.
-- Each breadcrumb can reference the previous one for continuity tracking.
-- ============================================================================

CREATE TABLE IF NOT EXISTS breadcrumbs (
    rowid INTEGER PRIMARY KEY,
    id TEXT UNIQUE NOT NULL,
    summary TEXT NOT NULL,
    themes TEXT DEFAULT '[]' CHECK (json_valid(themes)),
    connections TEXT,
    questions TEXT DEFAULT '[]' CHECK (json_valid(questions)),
    momentum TEXT CHECK (momentum IS NULL OR momentum IN ('exploring', 'converging', 'scattered', 'dormant', 'breakthrough')),
    window_start TEXT NOT NULL,
    window_end TEXT NOT NULL,
    notes_considered INTEGER NOT NULL,
    prev_breadcrumb_id TEXT REFERENCES breadcrumbs(id) ON DELETE SET NULL,
    raw TEXT,
    generated_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_breadcrumbs_generated_at ON breadcrumbs(generated_at);

-- ============================================================================
-- TABLE: resources
-- ============================================================================
-- Reading list / resource queue: articles, books, videos, papers, etc.
-- Tracks status (queued → reading → finished) and optional rating.
-- ============================================================================

CREATE TABLE IF NOT EXISTS resources (
    rowid INTEGER PRIMARY KEY,
    id TEXT UNIQUE NOT NULL,
    url TEXT NOT NULL,
    title TEXT NOT NULL,
    resource_type TEXT NOT NULL CHECK (resource_type IN ('article', 'book', 'paper', 'video', 'podcast', 'repo', 'tool', 'course', 'thread', 'other')),
    status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'reading', 'finished', 'abandoned', 'reference')),
    author TEXT,
    domain TEXT,
    rating INTEGER CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    summary TEXT,
    tags TEXT DEFAULT '[]' CHECK (json_valid(tags)),
    added_at TEXT NOT NULL,
    finished_at TEXT,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_resources_status ON resources(status);
CREATE INDEX IF NOT EXISTS idx_resources_type ON resources(resource_type);

-- Auto-update updated_at on UPDATE
CREATE TRIGGER IF NOT EXISTS trg_resources_updated_at
AFTER UPDATE ON resources
FOR EACH ROW
BEGIN
    UPDATE resources SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
    WHERE rowid = NEW.rowid;
END;

-- ============================================================================
-- TABLE: clippings
-- ============================================================================
-- Highlighted passages / quotes from resources.
-- FK to resources table for structural relationship.
-- ============================================================================

CREATE TABLE IF NOT EXISTS clippings (
    rowid INTEGER PRIMARY KEY,
    id TEXT UNIQUE NOT NULL,
    content TEXT NOT NULL,
    annotation TEXT,
    location TEXT,
    chapter TEXT,
    source TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('readwise', 'kindle', 'manual', 'web', 'pdf', 'other')),
    resource_id TEXT REFERENCES resources(id) ON DELETE SET NULL,
    external_id TEXT,
    tags TEXT DEFAULT '[]' CHECK (json_valid(tags)),
    clipped_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_clippings_resource_id ON clippings(resource_id);
CREATE INDEX IF NOT EXISTS idx_clippings_source ON clippings(source);

-- ============================================================================
-- TABLE: reflections
-- ============================================================================
-- LLM-generated reflections: weekly reviews, theme synthesis, insights.
-- Can be promoted to a permanent note via promoted_to_note_id FK.
-- ============================================================================

CREATE TABLE IF NOT EXISTS reflections (
    rowid INTEGER PRIMARY KEY,
    id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    reflection_type TEXT NOT NULL CHECK (reflection_type IN ('weekly-review', 'theme-synthesis', 'question-exploration', 'connection-map', 'insight', 'custom')),
    template_used TEXT,
    prompt_context TEXT,
    model TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'reviewed', 'promoted', 'discarded')),
    epistemic TEXT DEFAULT 'fleeting' CHECK (epistemic IS NULL OR epistemic IN ('fleeting', 'developing', 'supported', 'settled')),
    rating INTEGER CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    feedback TEXT,
    promoted_to_note_id TEXT REFERENCES notes(id) ON DELETE SET NULL,
    generated_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_reflections_status ON reflections(status);
CREATE INDEX IF NOT EXISTS idx_reflections_type ON reflections(reflection_type);

-- Auto-update updated_at on UPDATE
CREATE TRIGGER IF NOT EXISTS trg_reflections_updated_at
AFTER UPDATE ON reflections
FOR EACH ROW
BEGIN
    UPDATE reflections SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
    WHERE rowid = NEW.rowid;
END;

-- ============================================================================
-- TABLE: links
-- ============================================================================
-- Generic relationship table for flexible many-to-many connections.
-- Use for graph relationships: linksTo, derivedFrom, analyzedNotes, etc.
-- Structural 1:N relationships (clipping→resource) use FK columns instead.
-- ============================================================================

CREATE TABLE IF NOT EXISTS links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    rel_type TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    UNIQUE(source_id, target_id, rel_type)
);

CREATE INDEX IF NOT EXISTS idx_links_source ON links(source_id, rel_type);
CREATE INDEX IF NOT EXISTS idx_links_target ON links(target_id, rel_type);
CREATE INDEX IF NOT EXISTS idx_links_rel_type ON links(rel_type);

-- ============================================================================
-- FTS5 VIRTUAL TABLE: notes_fts
-- ============================================================================
-- Full-text search on notes: title, body, and tags.
-- Uses content='notes' to reference the base table.
-- ============================================================================

CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
    title,
    body,
    tags,
    content='notes',
    content_rowid='rowid'
);

-- Sync trigger: INSERT
CREATE TRIGGER IF NOT EXISTS trg_notes_fts_insert
AFTER INSERT ON notes
BEGIN
    INSERT INTO notes_fts(rowid, title, body, tags)
    VALUES (NEW.rowid, NEW.title, NEW.body, NEW.tags);
END;

-- Sync trigger: DELETE
CREATE TRIGGER IF NOT EXISTS trg_notes_fts_delete
BEFORE DELETE ON notes
BEGIN
    INSERT INTO notes_fts(notes_fts, rowid, title, body, tags)
    VALUES ('delete', OLD.rowid, OLD.title, OLD.body, OLD.tags);
END;

-- Sync trigger: UPDATE (delete old, insert new)
CREATE TRIGGER IF NOT EXISTS trg_notes_fts_update_before
BEFORE UPDATE ON notes
BEGIN
    INSERT INTO notes_fts(notes_fts, rowid, title, body, tags)
    VALUES ('delete', OLD.rowid, OLD.title, OLD.body, OLD.tags);
END;

CREATE TRIGGER IF NOT EXISTS trg_notes_fts_update_after
AFTER UPDATE ON notes
BEGIN
    INSERT INTO notes_fts(rowid, title, body, tags)
    VALUES (NEW.rowid, NEW.title, NEW.body, NEW.tags);
END;

-- ============================================================================
-- FTS5 VIRTUAL TABLE: clippings_fts
-- ============================================================================
-- Full-text search on clippings: content, annotation, and tags.
-- ============================================================================

CREATE VIRTUAL TABLE IF NOT EXISTS clippings_fts USING fts5(
    content,
    annotation,
    tags,
    content='clippings',
    content_rowid='rowid'
);

-- Sync trigger: INSERT
CREATE TRIGGER IF NOT EXISTS trg_clippings_fts_insert
AFTER INSERT ON clippings
BEGIN
    INSERT INTO clippings_fts(rowid, content, annotation, tags)
    VALUES (NEW.rowid, NEW.content, NEW.annotation, NEW.tags);
END;

-- Sync trigger: DELETE
CREATE TRIGGER IF NOT EXISTS trg_clippings_fts_delete
BEFORE DELETE ON clippings
BEGIN
    INSERT INTO clippings_fts(clippings_fts, rowid, content, annotation, tags)
    VALUES ('delete', OLD.rowid, OLD.content, OLD.annotation, OLD.tags);
END;

-- Sync trigger: UPDATE (delete old, insert new)
CREATE TRIGGER IF NOT EXISTS trg_clippings_fts_update_before
BEFORE UPDATE ON clippings
BEGIN
    INSERT INTO clippings_fts(clippings_fts, rowid, content, annotation, tags)
    VALUES ('delete', OLD.rowid, OLD.content, OLD.annotation, OLD.tags);
END;

CREATE TRIGGER IF NOT EXISTS trg_clippings_fts_update_after
AFTER UPDATE ON clippings
BEGIN
    INSERT INTO clippings_fts(rowid, content, annotation, tags)
    VALUES (NEW.rowid, NEW.content, NEW.annotation, NEW.tags);
END;

-- ============================================================================
-- FTS5 VIRTUAL TABLE: reflections_fts
-- ============================================================================
-- Full-text search on reflections: title and content.
-- ============================================================================

CREATE VIRTUAL TABLE IF NOT EXISTS reflections_fts USING fts5(
    title,
    content,
    content='reflections',
    content_rowid='rowid'
);

-- Sync trigger: INSERT
CREATE TRIGGER IF NOT EXISTS trg_reflections_fts_insert
AFTER INSERT ON reflections
BEGIN
    INSERT INTO reflections_fts(rowid, title, content)
    VALUES (NEW.rowid, NEW.title, NEW.content);
END;

-- Sync trigger: DELETE
CREATE TRIGGER IF NOT EXISTS trg_reflections_fts_delete
BEFORE DELETE ON reflections
BEGIN
    INSERT INTO reflections_fts(reflections_fts, rowid, title, content)
    VALUES ('delete', OLD.rowid, OLD.title, OLD.content);
END;

-- Sync trigger: UPDATE (delete old, insert new)
CREATE TRIGGER IF NOT EXISTS trg_reflections_fts_update_before
BEFORE UPDATE ON reflections
BEGIN
    INSERT INTO reflections_fts(reflections_fts, rowid, title, content)
    VALUES ('delete', OLD.rowid, OLD.title, OLD.content);
END;

CREATE TRIGGER IF NOT EXISTS trg_reflections_fts_update_after
AFTER UPDATE ON reflections
BEGIN
    INSERT INTO reflections_fts(rowid, title, content)
    VALUES (NEW.rowid, NEW.title, NEW.content);
END;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
