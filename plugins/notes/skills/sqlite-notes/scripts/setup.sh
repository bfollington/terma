#!/bin/bash
# sqlite-notes setup script
# Initializes a notes database with full schema, views, FTS, and triggers
#
# Usage:
#   ./setup.sh                        # Creates ./.sqlite/notes.db
#   ./setup.sh /path/to/notes.db      # Creates at specified path

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets"

DB_PATH="${1:-./.sqlite/notes.db}"
DB_DIR="$(dirname "$DB_PATH")"

echo "=== sqlite-notes setup ==="
echo "Database: $DB_PATH"
echo ""

# Check prerequisites
if ! command -v sqlite3 &> /dev/null; then
    echo "Error: sqlite3 not found."
    exit 1
fi

if [ ! -f "$ASSETS_DIR/schema.sql" ]; then
    echo "Error: schema.sql not found at $ASSETS_DIR/schema.sql"
    exit 1
fi

if [ ! -f "$ASSETS_DIR/views.sql" ]; then
    echo "Error: views.sql not found at $ASSETS_DIR/views.sql"
    exit 1
fi

# Create directory
mkdir -p "$DB_DIR"

# Load schema (idempotent)
echo "Loading schema..."
{
    echo "PRAGMA trusted_schema=ON;"
    cat "$ASSETS_DIR/schema.sql"
} | sqlite3 "$DB_PATH"

# Load views (idempotent)
echo "Loading views..."
{
    echo "PRAGMA trusted_schema=ON;"
    cat "$ASSETS_DIR/views.sql"
} | sqlite3 "$DB_PATH"

# Verify
echo ""
echo "Tables:"
sqlite3 "$DB_PATH" ".tables"
echo ""
echo "Views:"
sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='view' ORDER BY name;"
echo ""
echo "=== Setup complete ==="
echo ""
echo "Quick start:"
echo "  sqlite3 $DB_PATH \"PRAGMA trusted_schema=ON; INSERT INTO notes (id, body, folder, origin, captured_at) VALUES ('N-' || strftime('%Y%m%d', 'now') || '-' || lower(hex(randomblob(4))), 'My first note!', 'inbox', 'me', strftime('%Y-%m-%dT%H:%M:%SZ', 'now'));\""
echo ""
echo "Note: PRAGMA trusted_schema=ON is required for FTS5 trigger operations."
