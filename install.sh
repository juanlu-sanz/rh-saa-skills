#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"

usage() {
  cat <<EOF
Usage: $(basename "$0") [update]

  (no args)   Symlink all skills into ~/.cursor/skills/ and ~/.claude/skills/
  update      Pull the latest version from git, then re-link

EOF
}

link_skills() {
  local target_base="$1"
  local tool_name="$2"

  if [[ ! -d "$target_base" ]]; then
    echo "  Skipping $tool_name (directory $target_base does not exist)"
    return
  fi

  for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$target_base/$skill_name"

    if [[ -L "$target" ]]; then
      echo "  $tool_name/$skill_name: symlink already exists, updating"
      rm "$target"
      ln -s "$skill_dir" "$target"
    elif [[ -d "$target" ]]; then
      echo "  $tool_name/$skill_name: WARNING - a local directory already exists, skipping"
      echo "    Remove $target manually if you want the shared version"
    else
      ln -s "$skill_dir" "$target"
      echo "  $tool_name/$skill_name: linked"
    fi
  done
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  update)
    echo "Pulling latest version..."
    git -C "$REPO_DIR" pull --ff-only
    echo ""
    echo "Linking skills..."
    link_skills "$HOME/.cursor/skills" "Cursor"
    link_skills "$HOME/.claude/skills" "Claude Code"
    echo ""
    echo "Done. Skills are up to date."
    ;;
  "")
    echo "Linking skills..."
    link_skills "$HOME/.cursor/skills" "Cursor"
    link_skills "$HOME/.claude/skills" "Claude Code"
    echo ""
    echo "Done. Run '$(basename "$0") update' to pull and re-link later."
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
