#!/usr/bin/env node
// Validate every SKILL.md parses the way the skills CLI parses it.
//
// The failure this exists to prevent: a malformed frontmatter block does not
// error, it makes the skill *disappear*. `npx skills add` skips it with a
// warning that scrolls past, and the skill is silently absent for every
// consumer. An unquoted ": " in a description is enough to do it.

import { readdirSync, readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const SKILL_GLOB_ROOTS = ['plugins'];
const errors = [];
const skills = [];

function findSkillFiles(dir) {
  const found = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const child = join(dir, entry.name);
    if (existsSync(join(child, 'SKILL.md'))) found.push(join(child, 'SKILL.md'));
    else found.push(...findSkillFiles(child));
  }
  return found;
}

// Minimal frontmatter parse mirroring the CLI's expectations: a leading `---`
// fence, a closing fence, and flat `key: value` pairs. Anything that would make
// a YAML parser see a nested mapping is what we are hunting for.
function parseFrontmatter(text, file) {
  if (!text.startsWith('---\n')) {
    errors.push(`${file}\n    no frontmatter block — skill is invisible to every agent`);
    return null;
  }
  const end = text.indexOf('\n---', 3);
  if (end === -1) {
    errors.push(`${file}\n    frontmatter block is never closed`);
    return null;
  }
  const fields = {};
  for (const line of text.slice(4, end).split('\n')) {
    if (!line.trim() || line.startsWith('#')) continue;
    const m = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!m) {
      errors.push(`${file}\n    unparseable frontmatter line: ${line.trim().slice(0, 60)}`);
      continue;
    }
    const [, key, rawValue] = m;
    const value = rawValue.trim();
    const quoted = /^['"]/.test(value);
    // An unquoted scalar containing ": " reads as a nested mapping and takes
    // the whole block down with it.
    if (!quoted && value.includes(': ')) {
      const at = value.indexOf(': ');
      errors.push(
        `${file}\n    ${key} contains an unquoted ": " — YAML reads this as a nested mapping\n` +
          `    near: ...${value.slice(Math.max(0, at - 30), at + 20)}...\n` +
          `    fix: use an em dash, or quote the whole value`
      );
    }
    fields[key] = value;
  }
  return fields;
}

for (const root of SKILL_GLOB_ROOTS) {
  if (!existsSync(root)) continue;
  for (const file of findSkillFiles(root)) {
    const fields = parseFrontmatter(readFileSync(file, 'utf8'), file);
    if (!fields) continue;

    for (const required of ['name', 'description']) {
      if (!fields[required]) {
        errors.push(`${file}\n    missing required frontmatter field: ${required}`);
      }
    }

    // The directory name is what the CLI installs as; a mismatch is confusing
    // rather than fatal, but it is always a mistake.
    const dirName = file.split('/').at(-2);
    if (fields.name && fields.name !== dirName) {
      errors.push(`${file}\n    name "${fields.name}" does not match directory "${dirName}"`);
    }

    if (fields.name) skills.push(fields.name);
  }
}

const dupes = skills.filter((n, i) => skills.indexOf(n) !== i);
for (const d of new Set(dupes)) {
  errors.push(`duplicate skill name across plugins: ${d} — one will shadow the other`);
}

if (errors.length) {
  console.error(`\n✗ ${errors.length} problem(s):\n`);
  for (const e of errors) console.error(`  ${e}\n`);
  process.exit(1);
}

console.log(`✓ ${skills.length} skills valid`);
