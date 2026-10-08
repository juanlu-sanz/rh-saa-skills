# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-10-08

### Added

- `antora-workshop` skill: generates structured Red Hat Scholars courseware
  workshops using AsciiDoc and Antora.

### Changed

- Restructured repository from Claude Code marketplace format to a shared
  skills repo for both Cursor and Claude Code.
- Removed personal path references from skill files.
- Made screenshot capture instructions tool-neutral with a Cursor-specific
  example block.

### Removed

- Old `plugins/` directory (openshift-poc and ansible-poc Claude Code plugins).
  These are preserved in the `legacy-plugins` tag.
- `.claude-plugin/marketplace.json`.
