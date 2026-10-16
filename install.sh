#!/usr/bin/env bash
# Symlink this repo's skills into coding agents' skill folders. See README.md or --help.
exec "$(dirname "$0")/scripts/skills.sh" install "$@"
