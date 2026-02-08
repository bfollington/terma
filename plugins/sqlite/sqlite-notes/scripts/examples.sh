#!/bin/bash
# sqlite-notes example workflows
# Demonstrates the full lifecycle of notes, resources, clippings, breadcrumbs, and reflections
#
# Usage:
#   ./examples.sh                    # Creates /tmp/demo-sqlite-notes.db
#   ./examples.sh /path/to/demo.db   # Creates at specified path

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_PATH="${1:-/tmp/demo-sqlite-notes.db}"

echo "=========================================="
echo "sqlite-notes workflow demonstration"
echo "Database: $DB_PATH"
echo "=========================================="
echo ""

# Initialize database with schema and views
echo "--- Setting up database ---"
"$SCRIPT_DIR/setup.sh" "$DB_PATH"
echo ""

# Helper: Execute SQL with PRAGMA trusted_schema
sql() {
    echo "PRAGMA trusted_schema=ON; $1" | sqlite3 "$DB_PATH"
}

# Helper: Display query with header
query() {
    echo "PRAGMA trusted_schema=ON; $2" | sqlite3 -header -column "$DB_PATH"
}

echo "=========================================="
echo "WORKFLOW 1: Quick Capture"
echo "=========================================="
echo ""
echo "Capturing 5 notes across different folders..."
echo ""

# 1. Fleeting inbox thought
echo "1. Fleeting inbox thought"
sql "
INSERT INTO notes (id, body, folder, origin, epistemic, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Distributed systems are fundamentally about managing partial failures and uncertainty',
  'inbox',
  'me',
  'fleeting',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-5 hours')
);
"

# 2. Journal entry with tags
echo "2. Journal entry with tags"
sql "
INSERT INTO notes (id, title, body, folder, origin, tags, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Team meeting - architecture decisions',
  'Key decisions from today''s architecture review:

- Moving to event-driven architecture for order processing
- Conway''s Law is showing up again - team structure mirrors system boundaries
- Need to explore CQRS for read/write separation',
  'journal',
  'me',
  json_array('meetings', 'architecture', 'team'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-4 hours')
);
"

# 3. External source note with URL
echo "3. External source note with URL"
sql "
INSERT INTO notes (id, title, body, folder, origin, source_url, source_title, tags, captured_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Lamport - Time and Ordering',
  'Logical clocks provide partial ordering without synchronized physical time.

Key insight: happens-before relation is transitive and defines causal dependencies.

Connection to our distributed tracing work - we need causal ordering, not wall-clock time.',
  'inbox',
  'external',
  'https://lamport.azurewebsites.net/pubs/time-clocks.pdf',
  'Time, Clocks, and the Ordering of Events in a Distributed System',
  json_array('distributed-systems', 'papers', 'consensus'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-3 hours')
);
"

# 4. Working note about an idea being developed
echo "4. Working note about an idea being developed"
sql "
INSERT INTO notes (id, title, body, folder, origin, epistemic, tags, captured_at, reviewed_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'API Design as Communication Protocol',
  'APIs are not just technical contracts - they are communication protocols between teams.

When teams are loosely coupled, APIs become the primary interface. The API design reveals:
- What information teams need to share
- What decisions are local vs. global
- Where coordination is required

This connects to Conway''s Law and microservices boundaries.

Questions to explore:
- How do we design APIs that minimize coordination?
- What patterns support team autonomy?',
  'working',
  'me',
  'developing',
  json_array('api-design', 'team-dynamics', 'architecture'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-2 hours'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-1 hour')
);
"

# 5. Permanent/settled note
echo "5. Permanent/settled note"
sql "
INSERT INTO notes (id, title, body, folder, origin, epistemic, tags, captured_at, reviewed_at)
VALUES (
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Conway''s Law',
  'Conway''s Law: Organizations which design systems are constrained to produce designs which are copies of the communication structures of these organizations.

Implications:
- System architecture mirrors organizational structure
- Changing architecture often requires organizational change
- Team boundaries should align with system boundaries
- Microservices reflect team autonomy

Evidence:
- Observed in multiple projects across different companies
- Empirical research supports this (see MacCormack 2012)
- Reverse Conway Maneuver uses this deliberately

This is a settled principle that should inform all architecture decisions.',
  'permanent',
  'me',
  'settled',
  json_array('architecture', 'organization', 'principles'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-30 days'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-25 days')
);
"

echo ""
echo "Notes captured. Checking inbox:"
echo ""
query "Inbox view" "SELECT * FROM v_inbox LIMIT 3;"
echo ""

echo "=========================================="
echo "WORKFLOW 2: Resources & Clippings"
echo "=========================================="
echo ""

# Add two resources
echo "Adding 2 resources to reading queue..."
sql "
INSERT INTO resources (id, url, title, resource_type, author, status, tags, added_at)
VALUES
  ('R-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
   'https://martinfowler.com/articles/microservices.html',
   'Microservices Guide',
   'article',
   'Martin Fowler',
   'queued',
   json_array('microservices', 'architecture'),
   strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-2 days')),

  ('R-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
   'https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-ongaro.pdf',
   'In Search of an Understandable Consensus Algorithm',
   'paper',
   'Diego Ongaro and John Ousterhout',
   'queued',
   json_array('consensus', 'raft', 'distributed-systems'),
   strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-1 day'));
"
echo ""

# Update first resource to 'reading'
echo "Starting to read first resource..."
RESOURCE_ID=$(sqlite3 "$DB_PATH" "SELECT id FROM resources WHERE title LIKE '%Microservices%' LIMIT 1;")
echo "Resource ID: $RESOURCE_ID"
sql "UPDATE resources SET status = 'reading' WHERE id = '$RESOURCE_ID';"
echo ""

# Add 2 clippings from that resource
echo "Capturing 2 clippings from resource..."
sql "
INSERT INTO clippings (id, content, annotation, location, source, resource_id, tags, clipped_at)
VALUES
  ('CL-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
   'The microservice architectural style is an approach to developing a single application as a suite of small services, each running in its own process and communicating with lightweight mechanisms.',
   'Key definition - emphasizes independence and lightweight communication',
   'Introduction',
   'manual',
   '$RESOURCE_ID',
   json_array('microservices', 'definition'),
   strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-30 minutes')),

  ('CL-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
   'You can have a team responsible for many microservices. But that team should be able to change each service independently, without coordinating with other teams.',
   'This connects directly to Conway''s Law and team autonomy',
   'Section: Organized around Business Capabilities',
   'manual',
   '$RESOURCE_ID',
   json_array('microservices', 'team-structure'),
   strftime('%Y-%m-%dT%H:%M:%SZ', 'now', '-15 minutes'));
"
echo ""

# Finish the resource with rating
echo "Finishing resource with rating..."
sql "
UPDATE resources
SET status = 'finished',
    rating = 4,
    summary = 'Comprehensive overview of microservices patterns and tradeoffs. Strong emphasis on organizational aspects.',
    finished_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
WHERE id = '$RESOURCE_ID';
"
echo ""

echo "Currently reading resources:"
query "Currently reading" "SELECT * FROM v_currently_reading;"
echo ""

echo "=========================================="
echo "WORKFLOW 3: Link Notes"
echo "=========================================="
echo ""

echo "Creating links between related notes..."

# Get some note IDs for linking
CONWAY_NOTE=$(sqlite3 "$DB_PATH" "SELECT id FROM notes WHERE title = 'Conway''s Law' LIMIT 1;")
API_NOTE=$(sqlite3 "$DB_PATH" "SELECT id FROM notes WHERE title LIKE '%API Design%' LIMIT 1;")
LAMPORT_NOTE=$(sqlite3 "$DB_PATH" "SELECT id FROM notes WHERE source_title LIKE '%Time%Clocks%' LIMIT 1;")
DISTRIBUTED_NOTE=$(sqlite3 "$DB_PATH" "SELECT id FROM notes WHERE body LIKE '%partial failures%' LIMIT 1;")

sql "
INSERT INTO links (source_id, target_id, rel_type)
VALUES
  ('$API_NOTE', '$CONWAY_NOTE', 'linksTo'),
  ('$LAMPORT_NOTE', '$DISTRIBUTED_NOTE', 'derivedFrom');
"

echo "Links created:"
echo "  - API Design note links to Conway's Law"
echo "  - Lamport note derived from distributed systems thought"
echo ""

echo "=========================================="
echo "WORKFLOW 4: Query Views"
echo "=========================================="
echo ""

echo "Inbox view:"
query "Inbox" "SELECT * FROM v_inbox LIMIT 3;"
echo ""

echo "Tag cloud (top 10):"
query "Tag cloud" "SELECT * FROM v_tag_cloud LIMIT 10;"
echo ""

echo "Reading queue:"
query "Reading queue" "SELECT * FROM v_reading_queue;"
echo ""

echo "Note graph for Conway's Law note:"
query "Note graph" "SELECT * FROM v_note_graph WHERE center_id = '$CONWAY_NOTE';"
echo ""

echo "=========================================="
echo "WORKFLOW 5: Generate Breadcrumb"
echo "=========================================="
echo ""

echo "Generating breadcrumb analyzing recent notes..."

# Count recent notes
NOTE_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM notes WHERE folder IN ('inbox', 'working') AND captured_at >= date('now', '-7 days');")

sql "
INSERT INTO breadcrumbs (
  id, summary, themes, connections, questions, momentum,
  window_start, window_end, notes_considered, prev_breadcrumb_id, generated_at
)
VALUES (
  'BC-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Exploring connections between distributed systems theory and organizational design. Strong convergence around Conway''s Law as a unifying principle.',
  json_array('distributed-systems', 'architecture', 'team-dynamics', 'conways-law'),
  'Three themes emerging: 1) Distributed systems concepts apply to organization design, 2) API design as team communication protocol, 3) Causal ordering vs wall-clock time in both technical and organizational contexts.',
  json_array('How do we design systems that support organizational evolution?', 'What other distributed systems patterns apply to teams?', 'Can we measure organizational coupling like system coupling?'),
  'converging',
  strftime('%Y-%m-%dT%H:%M:%SZ', date('now', '-7 days')),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now'),
  $NOTE_COUNT,
  NULL,
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
"

BREADCRUMB_ID=$(sqlite3 "$DB_PATH" "SELECT id FROM breadcrumbs ORDER BY generated_at DESC LIMIT 1;")
echo "Created breadcrumb: $BREADCRUMB_ID"
echo ""

# Batch link breadcrumb to analyzed notes
echo "Batch linking breadcrumb to analyzed notes..."
sql "
INSERT INTO links (source_id, target_id, rel_type)
SELECT
  '$BREADCRUMB_ID',
  notes.id,
  'analyzedNotes'
FROM notes
WHERE (folder IN ('inbox', 'working'))
  AND captured_at >= date('now', '-7 days');
"

LINK_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM links WHERE source_id = '$BREADCRUMB_ID' AND rel_type = 'analyzedNotes';")
echo "Created $LINK_COUNT analyzedNotes links"
echo ""

echo "Latest breadcrumb:"
query "Latest breadcrumb" "SELECT id, summary, momentum, themes FROM v_latest_breadcrumb;"
echo ""

echo "=========================================="
echo "WORKFLOW 6: Generate Reflection"
echo "=========================================="
echo ""

echo "Generating reflection from notes and breadcrumbs..."

sql "
INSERT INTO reflections (
  id, title, content, reflection_type, model, status, epistemic, generated_at
)
VALUES (
  'RF-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  'Conway''s Law as Organizing Principle',
  '# Conway''s Law as Organizing Principle

This week''s notes reveal Conway''s Law emerging as a central organizing principle for both technical and organizational design.

## Key Insights

**1. APIs as Communication Protocols**

API design is not just a technical concern - it reflects and shapes how teams communicate. When we design an API, we are designing the communication protocol between teams. The API surface area reveals coordination requirements.

**2. Distributed Systems Patterns Apply to Organizations**

Concepts from distributed systems - partial failures, eventual consistency, causal ordering - apply equally to organizational design. Teams face similar challenges: asynchronous communication, independent decision-making, managing shared state.

**3. Architecture and Organization Co-evolve**

You cannot change architecture without considering organizational structure, and vice versa. The Reverse Conway Maneuver recognizes this: design the team structure to produce the architecture you want.

## Connections to Source Material

- Lamport''s work on logical clocks and causal ordering applies to team decision-making
- Microservices patterns reflect team autonomy requirements
- Event-driven architecture supports loose coupling between teams

## Questions to Explore

- Can we apply consensus algorithms to organizational decision-making?
- What is the organizational equivalent of eventual consistency?
- How do we measure and optimize for organizational coupling?

## Recommendation

This synthesis should be promoted to a permanent note. It connects multiple threads of thinking and provides a framework for future architecture and organization design decisions.',
  'theme-synthesis',
  'claude-sonnet-4-5-20250929',
  'draft',
  'developing',
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
);
"

REFLECTION_ID=$(sqlite3 "$DB_PATH" "SELECT id FROM reflections ORDER BY generated_at DESC LIMIT 1;")
echo "Created reflection: $REFLECTION_ID"
echo ""

# Batch link to source notes
echo "Linking reflection to source notes..."
sql "
INSERT INTO links (source_id, target_id, rel_type)
VALUES
  ('$REFLECTION_ID', '$CONWAY_NOTE', 'basedOnNotes'),
  ('$REFLECTION_ID', '$API_NOTE', 'basedOnNotes'),
  ('$REFLECTION_ID', '$LAMPORT_NOTE', 'basedOnNotes');
"

# Link to breadcrumb
sql "
INSERT INTO links (source_id, target_id, rel_type)
VALUES ('$REFLECTION_ID', '$BREADCRUMB_ID', 'basedOnBreadcrumbs');
"

echo "Linked reflection to 3 notes and 1 breadcrumb"
echo ""

# Promote reflection to permanent note
echo "Reviewing and promoting reflection..."
sql "
UPDATE reflections
SET status = 'reviewed',
    rating = 5,
    epistemic = 'supported',
    feedback = 'Excellent synthesis - connects multiple threads coherently and opens new questions'
WHERE id = '$REFLECTION_ID';
"

# Create permanent note from reflection
sql "
INSERT INTO notes (id, title, body, folder, origin, epistemic, tags, captured_at)
SELECT
  'N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))),
  title,
  content,
  'permanent',
  'llm-assisted',
  'supported',
  json_array('architecture', 'organization', 'conways-law', 'synthesis'),
  strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
FROM reflections
WHERE id = '$REFLECTION_ID';
"

PROMOTED_NOTE_ID=$(sqlite3 "$DB_PATH" "SELECT id FROM notes WHERE title LIKE '%Conway''s Law as Organizing%' LIMIT 1;")

# Update reflection with promoted_to_note_id
sql "
UPDATE reflections
SET promoted_to_note_id = '$PROMOTED_NOTE_ID',
    status = 'promoted'
WHERE id = '$REFLECTION_ID';
"

echo "Reflection promoted to permanent note: $PROMOTED_NOTE_ID"
echo ""

echo "=========================================="
echo "WORKFLOW 7: Full-Text Search"
echo "=========================================="
echo ""

echo "Search for 'distributed AND systems':"
query "FTS search" "
SELECT n.id, n.title, snippet(notes_fts, 1, '>>>', '<<<', '...', 30) AS match
FROM notes_fts
JOIN notes n ON notes_fts.rowid = n.rowid
WHERE notes_fts MATCH 'distributed AND systems'
ORDER BY rank
LIMIT 3;
"
echo ""

echo "Search clippings for 'team':"
query "Clipping search" "
SELECT c.id, snippet(clippings_fts, 0, '**', '**', '...', 40) AS match
FROM clippings_fts
JOIN clippings c ON clippings_fts.rowid = c.rowid
WHERE clippings_fts MATCH 'team'
ORDER BY rank;
"
echo ""

echo "Phrase search for 'Conway''s Law' in reflections:"
query "Reflection search" "
SELECT r.id, r.title, snippet(reflections_fts, 1, '>>>', '<<<', '...', 50) AS match
FROM reflections_fts
JOIN reflections r ON reflections_fts.rowid = r.rowid
WHERE reflections_fts MATCH '\"Conway''s Law\"'
ORDER BY rank;
"
echo ""

echo "=========================================="
echo "WORKFLOW 8: Aggregations"
echo "=========================================="
echo ""

echo "Monthly activity:"
query "Monthly activity" "SELECT * FROM v_monthly_activity;"
echo ""

echo "Resource stats:"
query "Resource stats" "SELECT * FROM v_resource_stats;"
echo ""

echo "Notes by origin:"
query "Origin breakdown" "
SELECT origin, COUNT(*) AS count
FROM notes
GROUP BY origin
ORDER BY count DESC;
"
echo ""

echo "Notes by folder:"
query "Folder breakdown" "
SELECT folder, COUNT(*) AS count
FROM notes
GROUP BY folder
ORDER BY count DESC;
"
echo ""

echo "Epistemic status distribution:"
query "Epistemic distribution" "
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
"
echo ""

echo "=========================================="
echo "WORKFLOW 9: Final Stats"
echo "=========================================="
echo ""

echo "Database summary:"
query "Table counts" "
SELECT
  (SELECT COUNT(*) FROM notes) AS notes,
  (SELECT COUNT(*) FROM breadcrumbs) AS breadcrumbs,
  (SELECT COUNT(*) FROM resources) AS resources,
  (SELECT COUNT(*) FROM clippings) AS clippings,
  (SELECT COUNT(*) FROM reflections) AS reflections,
  (SELECT COUNT(*) FROM links) AS links;
"
echo ""

echo "=========================================="
echo "Demo Complete!"
echo "=========================================="
echo ""
echo "Database preserved at: $DB_PATH"
echo ""
echo "Try exploring with:"
echo "  sqlite3 $DB_PATH"
echo ""
echo "Example queries:"
echo "  SELECT * FROM v_inbox;"
echo "  SELECT * FROM v_evergreen;"
echo "  SELECT * FROM v_tag_cloud;"
echo "  SELECT * FROM v_note_richness;"
echo ""
