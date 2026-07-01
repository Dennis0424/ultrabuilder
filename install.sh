#!/bin/bash
# UltraBuilder installer - copies skills to your Claude Code skills directory

SKILLS_DIR="${HOME}/.claude/skills"

# Detect OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    SKILLS_DIR="${USERPROFILE}/.claude/skills"
fi

echo "Installing UltraBuilder skills to: $SKILLS_DIR"
echo ""

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Copy each skill
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"

count=0
for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$SKILLS_DIR/$skill_name"
    cp "$skill_dir"SKILL.md "$SKILLS_DIR/$skill_name/SKILL.md"
    count=$((count + 1))
    echo "  Installed: /$(basename "$skill_dir")"
done

echo ""
echo "Done! Installed $count skills."
echo ""
echo "Usage:"
echo "  /ultrabuilder       - Full pipeline"
echo "  /office-hours       - Challenge your idea"
echo "  /build-execute      - Jump to implementation"
echo "  /investigate        - Debug systematically"
echo "  /health             - Check code quality"
echo ""
echo "See README.md for full documentation."
