-- SQLite Notes Skill — Views (Saved Queries)
--
-- This file defines views for common access patterns in the sqlite-notes skill.
-- Views are essentially saved queries that can be referenced like tables.
-- All views use CREATE VIEW IF NOT EXISTS for idempotent initialization.
--
-- View categories:
-- - Workflow Views: inbox, working, evergreen, stale_working
-- - Resource Views: reading_queue, currently_reading
-- - AI Content Views: latest_breadcrumb, draft_reflections
-- - Analytics Views: tag_cloud, monthly_activity, resource_stats
-- - Graph Views: note_graph, note_richness

-- ============================================================================
-- WORKFLOW VIEWS
-- ============================================================================

-- v_inbox: Notes in inbox folder for triage and initial processing
CREATE VIEW IF NOT EXISTS v_inbox AS
SELECT
    id,
    title,
    substr(body, 1, 120) AS preview,
    origin,
    tags,
    captured_at
FROM notes
WHERE folder = 'inbox'
ORDER BY captured_at DESC;

-- v_working: Notes being actively developed in working folder
CREATE VIEW IF NOT EXISTS v_working AS
SELECT
    id,
    title,
    substr(body, 1, 120) AS preview,
    epistemic,
    tags,
    captured_at,
    reviewed_at
FROM notes
WHERE folder = 'working'
ORDER BY captured_at DESC;

-- v_evergreen: Notes in permanent/evergreen folder
CREATE VIEW IF NOT EXISTS v_evergreen AS
SELECT
    id,
    title,
    substr(body, 1, 120) AS preview,
    origin,
    epistemic,
    tags,
    captured_at
FROM notes
WHERE folder = 'permanent'
ORDER BY captured_at DESC;

-- v_stale_working: Working notes not reviewed in 30+ days (needs attention)
CREATE VIEW IF NOT EXISTS v_stale_working AS
SELECT
    id,
    title,
    folder,
    reviewed_at,
    CAST(julianday('now') - julianday(reviewed_at) AS INTEGER) AS days_since_review
FROM notes
WHERE folder = 'working'
  AND (reviewed_at IS NULL OR reviewed_at < date('now', '-30 days'))
ORDER BY reviewed_at ASC;

-- ============================================================================
-- RESOURCE VIEWS
-- ============================================================================

-- v_reading_queue: Resources queued for reading (backlog)
CREATE VIEW IF NOT EXISTS v_reading_queue AS
SELECT
    id,
    title,
    resource_type,
    author,
    tags,
    added_at
FROM resources
WHERE status = 'queued'
ORDER BY added_at ASC;

-- v_currently_reading: Resources being actively read with clip counts
CREATE VIEW IF NOT EXISTS v_currently_reading AS
SELECT
    r.id,
    r.title,
    r.resource_type,
    r.author,
    (SELECT COUNT(*) FROM clippings WHERE resource_id = r.id) AS clip_count
FROM resources r
WHERE r.status = 'reading'
ORDER BY r.added_at ASC;

-- ============================================================================
-- AI CONTENT VIEWS
-- ============================================================================

-- v_latest_breadcrumb: Most recent breadcrumb for quick context
CREATE VIEW IF NOT EXISTS v_latest_breadcrumb AS
SELECT *
FROM breadcrumbs
ORDER BY generated_at DESC
LIMIT 1;

-- v_draft_reflections: AI reflections in draft state (not yet reviewed)
CREATE VIEW IF NOT EXISTS v_draft_reflections AS
SELECT
    id,
    title,
    reflection_type,
    generated_at
FROM reflections
WHERE status = 'draft'
ORDER BY generated_at DESC;

-- ============================================================================
-- ANALYTICS VIEWS
-- ============================================================================

-- v_tag_cloud: Tag usage statistics across all notes
CREATE VIEW IF NOT EXISTS v_tag_cloud AS
SELECT
    value AS tag,
    COUNT(*) AS count
FROM notes,
     json_each(notes.tags)
WHERE tags != '[]'
GROUP BY tag
ORDER BY count DESC;

-- v_monthly_activity: Note creation counts by month and folder
CREATE VIEW IF NOT EXISTS v_monthly_activity AS
SELECT
    strftime('%Y-%m', captured_at) AS month,
    folder,
    COUNT(*) AS note_count
FROM notes
GROUP BY month, folder
ORDER BY month DESC;

-- v_resource_stats: Resource counts and average ratings by type and status
CREATE VIEW IF NOT EXISTS v_resource_stats AS
SELECT
    resource_type,
    status,
    COUNT(*) AS count,
    AVG(rating) AS avg_rating
FROM resources
GROUP BY resource_type, status
ORDER BY resource_type, status;

-- ============================================================================
-- GRAPH VIEWS
-- ============================================================================

-- v_note_graph: Bidirectional view of note relationships (incoming + outgoing links)
-- Usage: SELECT * FROM v_note_graph WHERE center_id = 'N-20260208-a1b2';
CREATE VIEW IF NOT EXISTS v_note_graph AS
-- Outgoing links (this note links to others)
SELECT
    l.source_id AS center_id,
    'outgoing' AS direction,
    l.rel_type,
    l.target_id AS linked_id,
    COALESCE(n.title, substr(n.body, 1, 60)) AS linked_title
FROM links l
LEFT JOIN notes n ON l.target_id = n.id
WHERE l.source_id LIKE 'N-%'
  AND l.target_id LIKE 'N-%'

UNION ALL

-- Incoming links (other notes link to this note)
SELECT
    l.target_id AS center_id,
    'incoming' AS direction,
    l.rel_type,
    l.source_id AS linked_id,
    COALESCE(n.title, substr(n.body, 1, 60)) AS linked_title
FROM links l
LEFT JOIN notes n ON l.source_id = n.id
WHERE l.source_id LIKE 'N-%'
  AND l.target_id LIKE 'N-%';

-- v_note_richness: Notes ranked by their connectivity (links + tags)
CREATE VIEW IF NOT EXISTS v_note_richness AS
SELECT
    n.id,
    n.title,
    (SELECT COUNT(*) FROM links WHERE source_id = n.id) AS outgoing_links,
    (SELECT COUNT(*) FROM links WHERE target_id = n.id) AS incoming_links,
    (SELECT COUNT(*) FROM json_each(n.tags)) AS tag_count,
    (SELECT COUNT(*) FROM links WHERE source_id = n.id) +
    (SELECT COUNT(*) FROM links WHERE target_id = n.id) AS total_links
FROM notes n
ORDER BY total_links DESC, tag_count DESC;
