#!/usr/bin/env bash
# Remove the symlinks install.sh created. See README.md or --help.
exec "$(dirname "$0")/scripts/skills.sh" uninstall "$@"
