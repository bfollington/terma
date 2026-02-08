Bump the version of one or more plugins in this marketplace based on recent git changes.

## Steps

1. **Identify changed plugins.** Run `git log` to find commits since each plugin was last versioned. For each plugin directory under `plugins/` (`terma`, `tsal`, `notes`), check if there are commits touching files in that directory since the last version bump (look for commits that modified the plugin's `plugin.json` version field, or if none found, consider all recent commits).

   Use a command like:
   ```
   git log --oneline -- plugins/<name>/
   ```

   Compare this against the current version in both:
   - `plugins/<name>/.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json`

2. **Classify changes per plugin.** For each plugin with changes, review the commit messages and changed files to determine the appropriate semver bump:
   - **patch** (x.y.Z): Bug fixes, typo corrections, minor refinements to existing content
   - **minor** (x.Y.0): New skills, commands, agents, or significant content additions
   - **major** (X.0.0): Breaking changes, major reorganizations, renamed/removed skills or commands

3. **Present findings.** Show the user a summary table:
   - Plugin name
   - Current version
   - Number of new commits
   - Suggested bump type and new version
   - Key changes (1-2 line summary)

   If $ARGUMENTS is provided, treat it as a filter — only bump the named plugin(s) (comma-separated). Otherwise, show all plugins with changes.

4. **Ask for confirmation.** Let the user confirm or adjust the bump type for each plugin before proceeding.

5. **Apply version bumps.** For each confirmed plugin:
   - Update `plugins/<name>/.claude-plugin/plugin.json` — change the `"version"` field
   - Update `.claude-plugin/marketplace.json` — change the matching plugin's `"version"` field
   - Ensure both files stay in sync

6. **Do NOT commit automatically.** Just report what was changed so the user can review and commit when ready.
