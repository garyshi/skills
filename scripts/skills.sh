#!/usr/bin/env bash
# Install, uninstall, or list this repo's skills for several coding agents.
# Called through ../install.sh and ../uninstall.sh; see README.md.
#
# Every top-level folder with a SKILL.md is a skill. For Claude Code each skill
# is installed as a plugin from this repo's marketplace (built from the skills'
# frontmatter by build-marketplace.py); for the other agents the skill folder
# is symlinked into the agent's skill directory.
# Written for the macOS system bash (3.2): no associative arrays, no mapfile.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ALL_AGENTS="claude codex cursor grok antigravity"
MARKETPLACE="garyshi-skills"

usage() {
  local cmd="$1"
  cat <<EOF
Usage: $cmd.sh --agent NAME [--agent NAME ...] [options] [SKILL ...]
       $cmd.sh --all-agents [options] [SKILL ...]
       install.sh --list

Agents: $ALL_AGENTS  (comma-separated lists also work)

Options:
  -a, --agent NAME     Agent to $cmd for (repeatable)
      --all-agents     All supported agents
  -p, --project DIR    Use DIR's project-level setup instead of your home directory
  -n, --dry-run        Print what would change without changing anything
  -l, --list           Show the skills and where each one is installed
  -h, --help           Show this help

With no SKILL arguments, every skill in the repo is used.
EOF
}

die() { echo "error: $*" >&2; exit 1; }
say() { echo "$*"; }
# Path for display, with $HOME shortened to ~.
pretty() { case "$1" in "$HOME"/*) echo "~${1#"$HOME"}" ;; *) echo "$1" ;; esac; }

# --- skills ----------------------------------------------------------------

all_skills() {
  local f
  for f in "$REPO"/*/SKILL.md; do
    if [ -e "$f" ]; then basename "$(dirname "$f")"; fi
  done
}

is_skill() { [ -f "$REPO/$1/SKILL.md" ]; }

# True if the skill's frontmatter has `claude-only: "true"` under metadata.
is_claude_only() {
  awk 'NR == 1 { next } /^---$/ { exit } /^[ \t]+claude-only:[ \t]*"?true"?[ \t]*$/ { found = 1 } END { exit !found }' \
    "$REPO/$1/SKILL.md"
}

# --- symlink agents --------------------------------------------------------

# Skill directories for a non-Claude agent, one per line.
# $1 = agent, $2 = project dir or "".
agent_skill_dirs() {
  local agent="$1" proj="$2"
  if [ -n "$proj" ]; then
    case "$agent" in
      codex)       echo "$proj/.agents/skills" ;;
      cursor)      echo "$proj/.cursor/skills" ;;
      grok)        echo "$proj/.grok/skills" ;;
      antigravity) echo "$proj/.agents/skills" ;;
    esac
  else
    case "$agent" in
      codex)       echo "$HOME/.agents/skills" ;;
      cursor)      echo "$HOME/.cursor/skills" ;;
      grok)        echo "$HOME/.grok/skills" ;;
      # Desktop app + IDE, then the agy CLI.
      antigravity) echo "$HOME/.gemini/config/skills"
                   echo "$HOME/.gemini/antigravity-cli/skills" ;;
    esac
  fi
}

# True if $1 is a symlink pointing somewhere inside this repo.
links_into_repo() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in "$REPO"/*) return 0 ;; esac
  return 1
}

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "  ok       $(pretty "$dst") (already linked)"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if links_into_repo "$dst"; then
      say "  relink   $(pretty "$dst")"
      if [ -z "$DRY_RUN" ]; then rm "$dst"; fi
    else
      say "  SKIP     $(pretty "$dst") exists and is not a link into this repo; remove it yourself to install" >&2
      return
    fi
  else
    say "  link     $(pretty "$dst") -> $(pretty "$src")"
  fi
  if [ -n "$DRY_RUN" ]; then return; fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
}

unlink_if_ours() {
  local dst="$1"
  if links_into_repo "$dst"; then
    say "  remove   $(pretty "$dst")"
    if [ -z "$DRY_RUN" ]; then rm "$dst"; fi
  elif [ -e "$dst" ] || [ -L "$dst" ]; then
    say "  SKIP     $(pretty "$dst") is not a link into this repo; leaving it" >&2
  fi
}

# --- Claude Code (plugins) -------------------------------------------------

claude_scope() { if [ -n "$PROJECT" ]; then echo project; else echo user; fi; }

# Run a `claude plugin ...` command (from the project dir in project scope),
# or just print it in a dry run.
claude_run() {
  say "  run      claude $*"
  if [ -n "$DRY_RUN" ]; then return 0; fi
  if [ -n "$PROJECT" ]; then (cd "$PROJECT" && claude "$@"); else claude "$@"; fi
}

claude_json() {
  if [ -n "$PROJECT" ]; then (cd "$PROJECT" && claude "$@" --json 2>/dev/null); else claude "$@" --json 2>/dev/null; fi
}

claude_has_marketplace() {
  claude_json plugin marketplace list | grep -q "\"name\": *\"$MARKETPLACE\""
}

claude_installed() {
  claude_json plugin list | grep -q "\"id\": *\"$1@$MARKETPLACE\""
}

claude_install() {
  local skill
  if ! command -v claude >/dev/null; then say "  SKIP     the claude CLI is not on PATH" >&2; return 0; fi
  if ! python3 "$REPO/scripts/build-marketplace.py" --check >/dev/null 2>&1; then
    say "  warning: .claude-plugin/marketplace.json is out of date; run scripts/build-marketplace.py" >&2
  fi
  if claude_has_marketplace; then
    claude_run plugin marketplace update "$MARKETPLACE"
  else
    claude_run plugin marketplace add "$REPO" --scope "$(claude_scope)"
  fi
  for skill in $SKILLS; do
    if [ -z "$DRY_RUN" ] && claude_installed "$skill"; then
      claude_run plugin update "$skill@$MARKETPLACE" --scope "$(claude_scope)"
    else
      claude_run plugin install "$skill@$MARKETPLACE" --scope "$(claude_scope)"
    fi
  done
}

claude_uninstall() {
  local skill
  if ! command -v claude >/dev/null; then say "  SKIP     the claude CLI is not on PATH" >&2; return 0; fi
  for skill in $SKILLS; do
    if [ -n "$DRY_RUN" ] || claude_installed "$skill"; then
      claude_run plugin uninstall "$skill@$MARKETPLACE" --scope "$(claude_scope)"
    else
      say "  ok       $skill is not installed"
    fi
  done
  say "  (the $MARKETPLACE marketplace stays registered; remove it with: claude plugin marketplace remove $MARKETPLACE)"
}

# --- commands --------------------------------------------------------------

do_install() {
  local agent skill dir
  for agent in $AGENTS; do
    say "$agent:"
    if [ "$agent" = claude ]; then claude_install; continue; fi
    for skill in $SKILLS; do
      if is_claude_only "$skill"; then
        say "  skip     $skill (Claude Code only)"
        continue
      fi
      for dir in $(agent_skill_dirs "$agent" "$PROJECT"); do
        link "$REPO/$skill" "$dir/$skill"
      done
    done
  done
}

do_uninstall() {
  local agent skill dir
  for agent in $AGENTS; do
    say "$agent:"
    if [ "$agent" = claude ]; then claude_uninstall; continue; fi
    for skill in $SKILLS; do
      for dir in $(agent_skill_dirs "$agent" "$PROJECT"); do
        unlink_if_ours "$dir/$skill"
      done
    done
  done
  if [ -n "$PROJECT" ] && echo " $AGENTS " | grep -qE ' (codex|antigravity) '; then
    say "note: Codex and Antigravity share $(pretty "$PROJECT")/.agents/skills, so this removed the skills for both."
  fi
}

do_list() {
  local skill agent dir where claude_list=""
  if command -v claude >/dev/null; then claude_list="$(claude_json plugin list || true)"; fi
  for skill in $(all_skills); do
    if is_claude_only "$skill"; then say "$skill  (Claude Code only)"; else say "$skill"; fi
    if echo "$claude_list" | grep -q "\"id\": *\"$skill@$MARKETPLACE\""; then
      say "  claude: plugin $skill@$MARKETPLACE"
    fi
    for agent in $ALL_AGENTS; do
      if [ "$agent" = claude ]; then continue; fi
      where=""
      for dir in $(agent_skill_dirs "$agent" "$PROJECT"); do
        if links_into_repo "$dir/$skill"; then where="$where $(pretty "$dir")"; fi
      done
      if [ -n "$where" ]; then say "  $agent:$where"; fi
    done
  done
}

# --- main ------------------------------------------------------------------

main() {
  local cmd="$1"; shift
  AGENTS="" SKILLS="" PROJECT="" DRY_RUN="" LIST=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -a|--agent)   [ $# -ge 2 ] || die "$1 needs a value"; AGENTS="$AGENTS $(echo "$2" | tr ',' ' ')"; shift ;;
      --agent=*)    AGENTS="$AGENTS $(echo "${1#*=}" | tr ',' ' ')" ;;
      --all-agents) AGENTS="$ALL_AGENTS" ;;
      -p|--project) [ $# -ge 2 ] || die "$1 needs a directory"; PROJECT="$2"; shift ;;
      --project=*)  PROJECT="${1#*=}" ;;
      -n|--dry-run) DRY_RUN=1 ;;
      -l|--list)    LIST=1 ;;
      -h|--help)    usage "$cmd"; exit 0 ;;
      -*)           die "unknown option $1 (see --help)" ;;
      *)            SKILLS="$SKILLS $1" ;;
    esac
    shift
  done

  if [ -n "$PROJECT" ]; then
    [ -d "$PROJECT" ] || die "no such directory: $PROJECT"
    PROJECT="$(cd "$PROJECT" && pwd -P)"
  fi
  if [ -n "$LIST" ]; then do_list; exit 0; fi

  [ -n "$AGENTS" ] || { usage "$cmd" >&2; exit 1; }
  local a s
  for a in $AGENTS; do
    case " $ALL_AGENTS " in *" $a "*) ;; *) die "unknown agent '$a' (choose from: $ALL_AGENTS)" ;; esac
  done
  [ -n "$SKILLS" ] || SKILLS="$(all_skills)"
  for s in $SKILLS; do
    is_skill "$s" || die "unknown skill '$s' (choose from: $(all_skills | tr '\n' ' '))"
  done
  if [ -n "$DRY_RUN" ]; then say "(dry run: nothing will change)"; fi

  case "$cmd" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
    *)         die "unknown command $cmd" ;;
  esac
}

main "$@"
