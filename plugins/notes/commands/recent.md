# Recent - Headspace Briefing

Get back in the loop. Review recent thinking across notes, breadcrumbs, reflections, and resources to surface what you've been working on and where the interesting threads are.

## Arguments
- `$ARGUMENTS` - Optional: time window (e.g., "week", "month") or focus area (e.g., "creative-practice", "sqlite")

## Process

### 1. Gather Recent Material

Query recent items from each table, sorted by timestamp:

```bash
# Recent notes (last 20, sorted by capture time)
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, body, folder, origin, tags, captured_at
FROM notes
ORDER BY captured_at DESC
LIMIT 20;
SQL

# Recent breadcrumbs (last 5)
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, summary, themes, questions, momentum, generated_at
FROM breadcrumbs
ORDER BY generated_at DESC
LIMIT 5;
SQL

# Draft reflections (by update time)
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, reflection_type, status, generated_at, updated_at
FROM reflections
WHERE status IN ('draft', 'reviewed')
ORDER BY updated_at DESC
LIMIT 10;
SQL

# Recent resources
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, resource_type, status, author, added_at
FROM resources
ORDER BY added_at DESC
LIMIT 10;
SQL

# Recent clippings
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT c.id, c.content, c.annotation, r.title AS resource_title, c.clipped_at
FROM clippings c
LEFT JOIN resources r ON c.resource_id = r.id
ORDER BY c.clipped_at DESC
LIMIT 10;
SQL
```

If `$ARGUMENTS` contains a tag or topic, filter results:

```bash
# Filter notes by tag
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, body, tags, captured_at
FROM notes
WHERE EXISTS (SELECT 1 FROM json_each(tags) WHERE value = 'creative-practice')
ORDER BY captured_at DESC
LIMIT 20;
SQL
```

### 2. Analyze the Landscape

From the gathered material, identify:

**Active Threads**: What topics/themes appear across multiple recent notes? What's being actively developed?

**Breadcrumb Trail**: What do recent breadcrumbs say about momentum and direction? Are you exploring, converging, scattered, or breaking through?

**Reflection Status**: Which reflections are in draft? Which are reviewed but not yet promoted? Any ready for promotion?

**Unresolved Questions**: Collect open questions from breadcrumbs and notes. Which feel most alive?

**Neglected Areas**: Any tags or themes that used to appear but have gone quiet?

### 3. Present the Briefing

Format the output as a conversational briefing:

```
# Headspace Briefing
Generated: [timestamp]
Window: [date range of material reviewed]

## Where You've Been
[2-3 sentences summarizing the dominant themes and activities]

## Active Threads
- **[Theme 1]**: [brief status - what's happening, what's open]
- **[Theme 2]**: [brief status]
- **[Theme 3]**: [brief status]

## Recent Breadcrumbs
[List last 2-3 breadcrumbs with their momentum and key insight]

## Reflections in Progress
| Reflection | Type | Status | Last Updated | Notes |
|------------|------|--------|--------------|-------|
| [title] | [type] | [status] | [date] | [brief note on state] |

## Live Questions
Questions that feel most active or interesting right now:
1. [question from recent material]
2. [question]
3. [question]

## Entry Points
If you want to pick up where you left off:
- **Continue exploring**: [suggestion based on recent "exploring" momentum]
- **Push toward completion**: [suggestion based on reflections/converging work]
- **Start fresh**: [suggestion for neglected area or new thread]
```

### 4. Offer Follow-ups

After the briefing, offer:
- "Want me to expand on any thread?"
- "Should I pull up the full notes for [specific topic]?"
- "Ready to capture new thinking? (`/quick-capture`)"
- "Want to generate a breadcrumb? (`/crumb`)"

## Philosophy

- **Orientation, not summary**: The goal is to help you *find your way back*, not to exhaustively recap everything
- **Questions over answers**: Surfacing open questions is more valuable than summarizing closed ones
- **Momentum matters**: Knowing whether you're exploring vs converging changes how you approach the session
- **Multiple entry points**: Different days call for different modes - offer options

## Example Output

```
# Headspace Briefing
Generated: 2026-01-29T06:15:00Z
Window: Last 7 days (23 notes, 3 breadcrumbs, 2 reflections touched)

## Where You've Been
Heavy focus on creative practice frameworks - how to sustain output without
burning out, the "piece" as a category between sketch and product. Also
continuing sqlite-notes infrastructure work, testing whether "memhub is just
a skill + a database."

## Active Threads
- **Creative Practice**: New domain, 15 notes captured today. Three-tier model
  (sketch/garden/production), energy economics, publication strategy. Exploring phase.
- **SQLite Notes**: Ongoing. Schema design, views for common queries, FTS5 exploration.
  Converging toward clarity on workflow patterns.
- **Tools for Thought**: Quieter lately, but connected to both above threads.

## Recent Breadcrumbs
- **BC-20260129-a1b2** (exploring): Creative practice framework - pieces, tiers, capture
- **BC-20260125-c3d4** (converging): Feedback as essential friction, tight loops
- **BC-20260119-e5f6** (breakthrough): Agent-environment inseparability

## Reflections in Progress
| Reflection | Type | Status | Last Updated | Notes |
|------------|------|--------|--------------|-------|
| Weekly Review: Design Patterns | weekly-review | draft | 2d ago | Good synthesis, needs review |
| Creative Practice Themes | theme-synthesis | reviewed | 5d ago | Ready for promotion |

## Live Questions
1. How does the piece/tier framework apply to code? Is a CLI tool a piece?
2. What's the relationship between material-prep-as-logistics and knowledge foraging?
3. Where does collaboration fit in a framework oriented toward solo practice?

## Entry Points
- **Continue exploring**: Dig deeper into creative practice, especially code/tools angle
- **Push toward completion**: "Creative Practice Themes" reflection is ready for promotion
- **Start fresh**: Tools-for-thought has been quiet - any new angles there?
```

## Useful Queries

```bash
# Notes by specific tag
sqlite3 -json .sqlite/notes.db <<'SQL'
SELECT id, title, tags, captured_at
FROM notes
WHERE EXISTS (SELECT 1 FROM json_each(tags) WHERE value = 'creative-practice')
ORDER BY captured_at DESC;
SQL

# Breadcrumb trail (all breadcrumbs in order)
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, momentum, substr(summary, 1, 60) AS summary_preview, generated_at
FROM breadcrumbs
ORDER BY generated_at ASC;
SQL

# Reflections by status
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT id, title, reflection_type, status, generated_at
FROM reflections
WHERE status = 'draft'
ORDER BY generated_at DESC;
SQL

# Count notes by folder
sqlite3 -header -column .sqlite/notes.db <<'SQL'
SELECT folder, COUNT(*) AS count
FROM notes
GROUP BY folder
ORDER BY count DESC;
SQL

# Tag cloud (most used tags)
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_tag_cloud LIMIT 15;"

# Monthly activity
sqlite3 -header -column .sqlite/notes.db "SELECT * FROM v_monthly_activity LIMIT 12;"
```
