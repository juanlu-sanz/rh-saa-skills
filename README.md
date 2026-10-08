# rh-saa-skills

Shared AI skills for Red Hat Solution Architects. Works with both
[Cursor](https://cursor.com) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Skills

| Skill | Description |
|---|---|
| **antora-workshop** | Generates structured Red Hat Scholars courseware workshops using AsciiDoc and Antora, with progressive hands-on steps, collapsible verification blocks, and reset/undo sections |

## Install

### First time

Clone the repository and run the install script:

```bash
git clone https://github.com/juanlu-sanz/rh-saa-skills ~/.rh-saa-skills
~/.rh-saa-skills/install.sh
```

The script creates symlinks into `~/.cursor/skills/` and `~/.claude/skills/`
(only for the tools you have installed). Because these are symlinks, both tools
always read the same files.

### Update

When there's a new version:

```bash
~/.rh-saa-skills/install.sh update
```

This pulls the latest changes and re-links any new skills that were added.

### Get notified of updates

Set the repository's **Watch** option to **Releases only** on GitHub. You'll
get an email whenever a new version is tagged.

### Windows / Claude Desktop / Claude Web

Download the zip from the
[latest release](https://github.com/juanlu-sanz/rh-saa-skills/releases/latest)
and extract the skill folder into the appropriate directory. Updating means
downloading and extracting the new zip.

## How it works

Each skill is a directory under `skills/` containing a `SKILL.md` file (and
optionally supporting files like `reference.md`). Both Cursor and Claude Code
read `SKILL.md` files with the same format: YAML frontmatter with `name` and
`description`, followed by the full instructions.

The `install.sh` script symlinks each skill directory into the locations where
Cursor and Claude Code look for skills. Since they're symlinks, a `git pull`
in this repo instantly updates every linked tool.

## Repository Structure

```
rh-saa-skills/
├── skills/
│   └── antora-workshop/
│       ├── SKILL.md              # Skill instructions
│       └── reference.md          # Boilerplate templates
├── install.sh                    # Install and update script
├── CHANGELOG.md
├── README.md
├── .github/
│   ├── CODEOWNERS
│   ├── ISSUE_TEMPLATE/
│   │   └── skill-misfire.yml     # "The skill did the wrong thing" template
│   └── workflows/
│       ├── lint.yml              # Validates SKILL.md frontmatter on PRs
│       └── release.yml           # Zips skills and attaches to GitHub Releases
```

## Contributing

### Modifying a skill

1. Fork this repository and create a feature branch.
2. Edit the `SKILL.md` and/or supporting files under `skills/<name>/`.
3. Test the skill by running Cursor or Claude Code with the updated files.
4. Open a PR with a clear description of what changed and why. Include a
   sample prompt and summary of the output the AI produces.

### Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter:

   ```markdown
   ---
   name: my-skill
   description: >-
     When and why the AI should activate this skill.
     Be specific about trigger phrases.
   ---

   # Skill Title

   Instructions go here...
   ```

2. Add a supporting file (e.g. `templates.md`, `reference.md`) if the skill
   needs boilerplate templates.
3. Update this README's **Available Skills** table.
4. Open a PR.

### Reporting a skill misfire

If a skill triggered when it shouldn't have, or produced the wrong output,
[open an issue](https://github.com/juanlu-sanz/rh-saa-skills/issues/new?template=skill-misfire.yml)
with the prompt you used, what happened, and what you expected.

## Maintainer

Juanlu Sanz (jsanzmor@redhat.com)

## License

Apache-2.0
