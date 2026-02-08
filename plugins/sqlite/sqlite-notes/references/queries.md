# Advanced SQL Query Recipes

This document provides advanced SQL patterns for the sqlite-notes skill, organized by query technique. These go beyond the basic patterns shown in SKILL.md and demonstrate SQL's full power for knowledge management.

## 1. Full-Text Search Recipes

### Basic Search Across Notes

Search notes for a single term with snippets showing match context.

```sql
SELECT
  n.id,
  n.title,
  snippet(notes_fts, 1, '**', '**', '...', 30) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'consensus'
ORDER BY rank
LIMIT 10;
```

### Boolean Search (AND, OR, NOT)

Combine terms with boolean operators for precise searching.

```sql
-- Both terms must appear
SELECT n.id, n.title
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'distributed AND systems'
ORDER BY rank;

-- Either term (broader search)
SELECT n.id, n.title
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'consensus OR raft OR paxos'
ORDER BY rank;

-- Exclude term (refinement)
SELECT n.id, n.title
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'distributed NOT systems'
ORDER BY rank;
```

### Phrase Matching

Search for exact phrases using double quotes.

```sql
SELECT
  n.id,
  n.title,
  snippet(notes_fts, 1, '>>>', '<<<', '...', 40) AS match_context
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH '"Conway''s Law"'
ORDER BY rank;
```

### Ranked Results with BM25 Scoring

Return results ranked by relevance score (lower is more relevant).

```sql
SELECT
  n.id,
  n.title,
  bm25(notes_fts) AS relevance_score,
  snippet(notes_fts, 1, '>>>', '<<<', '...', 30) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'distributed systems'
ORDER BY bm25(notes_fts)
LIMIT 20;
```

### Search Across All Entity Types

Search notes, clippings, and reflections in a single query using UNION ALL.

```sql
SELECT 'note' AS type, n.id, n.title, n.captured_at AS timestamp
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'consensus'

UNION ALL

SELECT 'clipping' AS type, c.id, substr(c.content, 1, 60) AS title, c.clipped_at AS timestamp
FROM clippings_fts
JOIN clippings c ON clippings_fts.rowid = c.rowid
WHERE clippings_fts MATCH 'consensus'

UNION ALL

SELECT 'reflection' AS type, r.id, r.title, r.generated_at AS timestamp
FROM reflections_fts
JOIN reflections r ON reflections_fts.rowid = r.rowid
WHERE reflections_fts MATCH 'consensus'

ORDER BY timestamp DESC;
```

### Search with Folder/Origin Filter

Combine FTS with structured filters for targeted search.

```sql
SELECT
  n.id,
  n.title,
  n.folder,
  snippet(notes_fts, 1, '**', '**', '...', 30) AS snippet
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'architecture'
  AND n.folder IN ('working', 'permanent')
  AND n.origin = 'me'
ORDER BY rank;
```

## 2. JOIN Recipes

### Clippings from Highly-Rated Resources

Find all highlights from resources you rated 4 or 5 stars.

```sql
SELECT
  c.id AS clipping_id,
  c.content,
  c.annotation,
  r.title AS resource_title,
  r.author,
  r.rating
FROM clippings c
JOIN resources r ON c.resource_id = r.id
WHERE r.rating >= 4
ORDER BY r.rating DESC, c.clipped_at DESC;
```

### Notes with Their Linked Resource Titles

Show notes that reference external resources with the resource metadata.

```sql
SELECT
  n.id AS note_id,
  n.title AS note_title,
  r.title AS resource_title,
  r.author,
  r.url
FROM notes n
JOIN links l ON n.id = l.source_id
JOIN resources r ON l.target_id = r.id
WHERE l.rel_type = 'references'
ORDER BY n.captured_at DESC;
```

### Breadcrumbs with Analyzed Note Count and Titles

Show breadcrumbs with aggregated information about the notes they analyzed.

```sql
SELECT
  bc.id AS breadcrumb_id,
  bc.summary,
  bc.momentum,
  bc.generated_at,
  COUNT(l.target_id) AS analyzed_count,
  GROUP_CONCAT(n.title, ' | ') AS analyzed_titles
FROM breadcrumbs bc
LEFT JOIN links l ON bc.id = l.source_id AND l.rel_type = 'analyzedNotes'
LEFT JOIN notes n ON l.target_id = n.id
GROUP BY bc.id, bc.summary, bc.momentum, bc.generated_at
ORDER BY bc.generated_at DESC;
```

### Reflections with Source Material Lineage

Show reflections with all their source notes and breadcrumbs.

```sql
SELECT
  r.id AS reflection_id,
  r.title AS reflection_title,
  r.status,
  r.rating,
  GROUP_CONCAT(DISTINCT CASE WHEN l.rel_type = 'basedOnNotes' THEN n.title END, ' | ') AS source_notes,
  GROUP_CONCAT(DISTINCT CASE WHEN l.rel_type = 'basedOnBreadcrumbs' THEN bc.summary END, ' | ') AS source_breadcrumbs
FROM reflections r
LEFT JOIN links l ON r.id = l.source_id
LEFT JOIN notes n ON l.target_id = n.id AND l.rel_type = 'basedOnNotes'
LEFT JOIN breadcrumbs bc ON l.target_id = bc.id AND l.rel_type = 'basedOnBreadcrumbs'
WHERE r.status = 'promoted'
GROUP BY r.id, r.title, r.status, r.rating
ORDER BY r.generated_at DESC;
```

### Resource → Clippings → Notes Chain

Three-table join showing which notes use clippings from which resources.

```sql
SELECT
  r.title AS resource_title,
  r.author,
  c.content AS clipping,
  n.title AS note_title,
  n.folder AS note_folder
FROM resources r
JOIN clippings c ON r.id = c.resource_id
JOIN links l ON c.id = l.target_id AND l.rel_type = 'includesClipping'
JOIN notes n ON l.source_id = n.id
WHERE r.rating >= 4
ORDER BY r.title, c.clipped_at;
```

## 3. Aggregation Recipes

### Notes Per Folder Per Month

Track note creation trends over time by folder (same as v_monthly_activity view).

```sql
SELECT
  strftime('%Y-%m', captured_at) AS month,
  folder,
  COUNT(*) AS note_count
FROM notes
GROUP BY month, folder
ORDER BY month DESC, folder;
```

### Tag Frequency with Co-occurrence

Find which tags appear together most frequently.

```sql
-- Tag pairs that co-occur
SELECT
  t1.value AS tag1,
  t2.value AS tag2,
  COUNT(*) AS co_occurrence_count
FROM notes n
JOIN json_each(n.tags) t1
JOIN json_each(n.tags) t2
WHERE json_valid(n.tags)
  AND t1.value < t2.value  -- Avoid duplicates and self-pairs
GROUP BY t1.value, t2.value
HAVING COUNT(*) >= 2
ORDER BY co_occurrence_count DESC
LIMIT 20;
```

### Epistemic Progression by Folder

Show how many notes are at each epistemic status within each folder.

```sql
SELECT
  folder,
  COUNT(*) AS total_notes,
  COUNT(CASE WHEN epistemic = 'fleeting' THEN 1 END) AS fleeting,
  COUNT(CASE WHEN epistemic = 'developing' THEN 1 END) AS developing,
  COUNT(CASE WHEN epistemic = 'supported' THEN 1 END) AS supported,
  COUNT(CASE WHEN epistemic = 'settled' THEN 1 END) AS settled
FROM notes
WHERE epistemic IS NOT NULL
GROUP BY folder
ORDER BY folder;
```

### Resource Completion Rate by Type

Calculate what percentage of each resource type gets finished vs abandoned.

```sql
SELECT
  resource_type,
  COUNT(*) AS total,
  COUNT(CASE WHEN status = 'finished' THEN 1 END) AS finished,
  COUNT(CASE WHEN status = 'abandoned' THEN 1 END) AS abandoned,
  ROUND(100.0 * COUNT(CASE WHEN status = 'finished' THEN 1 END) / COUNT(*), 1) AS completion_rate
FROM resources
WHERE status IN ('finished', 'abandoned')
GROUP BY resource_type
ORDER BY completion_rate DESC;
```

### Average Time from Queued to Finished

Calculate how long resources spend in your reading queue before completion.

```sql
SELECT
  resource_type,
  COUNT(*) AS finished_count,
  ROUND(AVG(julianday(finished_at) - julianday(added_at)), 1) AS avg_days_to_finish
FROM resources
WHERE status = 'finished'
  AND finished_at IS NOT NULL
GROUP BY resource_type
ORDER BY avg_days_to_finish;
```

## 4. Window Function Recipes

### Breadcrumb Momentum Trend

Show how momentum changes over time using LAG to compare with previous breadcrumb.

```sql
SELECT
  id,
  summary,
  momentum,
  generated_at,
  LAG(momentum) OVER (ORDER BY generated_at) AS prev_momentum,
  CASE
    WHEN momentum = 'breakthrough' THEN '! Breakthrough'
    WHEN momentum = LAG(momentum) OVER (ORDER BY generated_at) THEN '→ Stable'
    WHEN momentum = 'converging' AND LAG(momentum) OVER (ORDER BY generated_at) = 'exploring' THEN '↗ Focusing'
    WHEN momentum = 'exploring' AND LAG(momentum) OVER (ORDER BY generated_at) = 'converging' THEN '↙ Diverging'
    ELSE '↔ Changing'
  END AS trend
FROM breadcrumbs
ORDER BY generated_at DESC;
```

### Running Total of Notes Captured Per Week

Calculate cumulative note capture over time.

```sql
SELECT
  strftime('%Y-W%W', captured_at) AS week,
  COUNT(*) AS notes_this_week,
  SUM(COUNT(*)) OVER (ORDER BY strftime('%Y-W%W', captured_at)) AS total_notes
FROM notes
GROUP BY week
ORDER BY week DESC
LIMIT 20;
```

### Note Capture Velocity (Rolling 7-Day Window)

Calculate notes per day over a rolling 7-day window to see capture trends.

```sql
SELECT
  date(captured_at) AS day,
  COUNT(*) AS notes_today,
  AVG(COUNT(*)) OVER (
    ORDER BY date(captured_at)
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS avg_notes_7day
FROM notes
GROUP BY day
ORDER BY day DESC
LIMIT 30;
```

### Rank Notes by Link Count Within Each Folder

Show the most connected notes in each folder using window functions.

```sql
SELECT
  folder,
  id,
  title,
  link_count,
  RANK() OVER (PARTITION BY folder ORDER BY link_count DESC) AS rank_in_folder
FROM (
  SELECT
    n.folder,
    n.id,
    n.title,
    (SELECT COUNT(*) FROM links WHERE source_id = n.id OR target_id = n.id) AS link_count
  FROM notes n
)
WHERE rank_in_folder <= 5
ORDER BY folder, rank_in_folder;
```

## 5. CTE Recipes

### Full Lineage of a Promoted Reflection

Trace backwards from a promoted note through reflection, breadcrumbs, and source notes.

```sql
WITH RECURSIVE lineage AS (
  -- Start with the promoted note
  SELECT
    id,
    title AS text,
    'note' AS entity_type,
    captured_at AS timestamp,
    0 AS depth
  FROM notes
  WHERE id = 'N-20260208-xyz123'  -- Replace with actual note ID

  UNION ALL

  -- Follow links backwards
  SELECT
    l.source_id AS id,
    COALESCE(
      (SELECT title FROM notes WHERE id = l.source_id),
      (SELECT title FROM reflections WHERE id = l.source_id),
      (SELECT summary FROM breadcrumbs WHERE id = l.source_id)
    ) AS text,
    CASE
      WHEN l.source_id LIKE 'N-%' THEN 'note'
      WHEN l.source_id LIKE 'RF-%' THEN 'reflection'
      WHEN l.source_id LIKE 'BC-%' THEN 'breadcrumb'
    END AS entity_type,
    COALESCE(
      (SELECT captured_at FROM notes WHERE id = l.source_id),
      (SELECT generated_at FROM reflections WHERE id = l.source_id),
      (SELECT generated_at FROM breadcrumbs WHERE id = l.source_id)
    ) AS timestamp,
    lineage.depth + 1 AS depth
  FROM lineage
  JOIN links l ON lineage.id = l.target_id
  WHERE lineage.depth < 10
)
SELECT * FROM lineage
ORDER BY depth, timestamp DESC;
```

### Breadcrumb Chain Traversal

Follow the breadcrumb trail backwards through prev_breadcrumb_id references.

```sql
WITH RECURSIVE breadcrumb_chain AS (
  -- Start with most recent breadcrumb
  SELECT
    id,
    summary,
    momentum,
    generated_at,
    prev_breadcrumb_id,
    1 AS position
  FROM breadcrumbs
  ORDER BY generated_at DESC
  LIMIT 1

  UNION ALL

  -- Follow prev_breadcrumb_id links
  SELECT
    bc.id,
    bc.summary,
    bc.momentum,
    bc.generated_at,
    bc.prev_breadcrumb_id,
    chain.position + 1
  FROM breadcrumb_chain chain
  JOIN breadcrumbs bc ON chain.prev_breadcrumb_id = bc.id
  WHERE chain.position < 10
)
SELECT * FROM breadcrumb_chain
ORDER BY position;
```

### Orphan Detection

Find notes with no incoming or outgoing links.

```sql
WITH linked_notes AS (
  SELECT DISTINCT source_id AS id FROM links
  WHERE source_id LIKE 'N-%'
  UNION
  SELECT DISTINCT target_id AS id FROM links
  WHERE target_id LIKE 'N-%'
)
SELECT
  n.id,
  n.title,
  n.folder,
  n.captured_at
FROM notes n
WHERE n.id NOT IN (SELECT id FROM linked_notes)
  AND n.folder IN ('working', 'permanent')
ORDER BY n.captured_at DESC;
```

### Connected Components (Note Clusters)

Find clusters of interconnected notes using recursive traversal.

```sql
WITH RECURSIVE components AS (
  -- Seed: pick an unvisited note
  SELECT
    id,
    id AS component_id,
    1 AS depth
  FROM notes
  WHERE id = 'N-20260208-abc123'  -- Replace with starting note

  UNION

  -- Traverse links bidirectionally
  SELECT
    CASE
      WHEN l.source_id LIKE 'N-%' AND l.source_id NOT IN (SELECT id FROM components) THEN l.source_id
      WHEN l.target_id LIKE 'N-%' AND l.target_id NOT IN (SELECT id FROM components) THEN l.target_id
    END AS id,
    c.component_id,
    c.depth + 1
  FROM components c
  JOIN links l ON (c.id = l.source_id OR c.id = l.target_id)
  WHERE (l.source_id LIKE 'N-%' OR l.target_id LIKE 'N-%')
    AND c.depth < 20
)
SELECT
  n.id,
  n.title,
  c.component_id,
  c.depth
FROM components c
JOIN notes n ON c.id = n.id
ORDER BY c.depth, n.title;
```

## 6. Dashboard Queries

### Overall Stats Summary

Quick snapshot of database health and activity.

```sql
SELECT
  'Total Notes' AS metric,
  CAST(COUNT(*) AS TEXT) AS value
FROM notes

UNION ALL

SELECT 'Inbox Count', CAST(COUNT(*) AS TEXT)
FROM notes WHERE folder = 'inbox'

UNION ALL

SELECT 'Permanent Notes', CAST(COUNT(*) AS TEXT)
FROM notes WHERE folder = 'permanent'

UNION ALL

SELECT 'Total Resources', CAST(COUNT(*) AS TEXT)
FROM resources

UNION ALL

SELECT 'Reading Queue', CAST(COUNT(*) AS TEXT)
FROM resources WHERE status = 'queued'

UNION ALL

SELECT 'Total Clippings', CAST(COUNT(*) AS TEXT)
FROM clippings

UNION ALL

SELECT 'Total Breadcrumbs', CAST(COUNT(*) AS TEXT)
FROM breadcrumbs

UNION ALL

SELECT 'Total Reflections', CAST(COUNT(*) AS TEXT)
FROM reflections

UNION ALL

SELECT 'Promoted Reflections', CAST(COUNT(*) AS TEXT)
FROM reflections WHERE status = 'promoted';
```

### Inbox Health Check

Monitor inbox size, oldest unreviewed item, and average age.

```sql
SELECT
  COUNT(*) AS inbox_count,
  MIN(captured_at) AS oldest_capture,
  CAST(julianday('now') - julianday(MIN(captured_at)) AS INTEGER) AS oldest_age_days,
  CAST(AVG(julianday('now') - julianday(captured_at)) AS INTEGER) AS avg_age_days
FROM notes
WHERE folder = 'inbox';
```

### Reading Pipeline Status

Track resources at each stage of the reading workflow.

```sql
SELECT
  status,
  COUNT(*) AS count,
  ROUND(AVG(CASE WHEN rating IS NOT NULL THEN rating END), 1) AS avg_rating
FROM resources
GROUP BY status
ORDER BY
  CASE status
    WHEN 'queued' THEN 1
    WHEN 'reading' THEN 2
    WHEN 'finished' THEN 3
    WHEN 'reference' THEN 4
    WHEN 'abandoned' THEN 5
  END;
```

### Knowledge Growth Metrics

Track permanent note creation and reflection promotion over time.

```sql
SELECT
  strftime('%Y-%m', captured_at) AS month,
  COUNT(*) AS permanent_notes_created,
  (SELECT COUNT(*)
   FROM reflections
   WHERE status = 'promoted'
     AND strftime('%Y-%m', generated_at) = strftime('%Y-%m', notes.captured_at)
  ) AS reflections_promoted
FROM notes
WHERE folder = 'permanent'
GROUP BY month
ORDER BY month DESC
LIMIT 12;
```

### Recent Activity Summary (Last 7 Days)

Show what happened in the past week across all entity types.

```sql
SELECT
  'Notes Captured' AS activity,
  COUNT(*) AS count
FROM notes
WHERE captured_at >= date('now', '-7 days')

UNION ALL

SELECT 'Resources Added', COUNT(*)
FROM resources
WHERE added_at >= date('now', '-7 days')

UNION ALL

SELECT 'Clippings Created', COUNT(*)
FROM clippings
WHERE clipped_at >= date('now', '-7 days')

UNION ALL

SELECT 'Breadcrumbs Generated', COUNT(*)
FROM breadcrumbs
WHERE generated_at >= date('now', '-7 days')

UNION ALL

SELECT 'Reflections Created', COUNT(*)
FROM reflections
WHERE generated_at >= date('now', '-7 days')

UNION ALL

SELECT 'Links Created', COUNT(*)
FROM links
WHERE created_at >= date('now', '-7 days');
```

### Epistemic Progress Tracker

Monitor how notes are progressing through epistemic stages over time.

```sql
SELECT
  strftime('%Y-%m', reviewed_at) AS review_month,
  COUNT(*) AS notes_reviewed,
  COUNT(CASE WHEN epistemic = 'supported' THEN 1 END) AS reached_supported,
  COUNT(CASE WHEN epistemic = 'settled' THEN 1 END) AS reached_settled
FROM notes
WHERE reviewed_at IS NOT NULL
  AND reviewed_at >= date('now', '-6 months')
GROUP BY review_month
ORDER BY review_month DESC;
```

---

## Usage Tips

1. **Test on Sample Data First**: Run these queries on a test database before production to understand output format.

2. **Parameterize When Needed**: Replace literal IDs (like `'N-20260208-abc123'`) with subqueries or pass them as variables.

3. **Use EXPLAIN QUERY PLAN**: Prefix queries with `EXPLAIN QUERY PLAN` to verify index usage for performance.

4. **Build from Simple to Complex**: Start with simple JOINs, then add CTEs and window functions as needed.

5. **Save Useful Queries as Views**: If you run a query frequently, save it as a view in views.sql.

6. **Combine Techniques**: These recipes can be combined - use CTEs with window functions, JOINs with FTS, etc.

7. **Format for Readability**: Use consistent indentation and line breaks to make complex queries maintainable.

8. **Comment Complex Logic**: Add SQL comments (`-- comment`) to explain non-obvious patterns.
