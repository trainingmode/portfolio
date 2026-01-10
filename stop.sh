#!/bin/bash
#
# stop.sh — Terminates all running Sasha CLIs for this project.
#
# Usage:
#   ./stop.sh            # stop all running Sasha instances for this repo
#   ./stop.sh --dry-run  # show what would be terminated
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSG_PATH="${SCRIPT_DIR}/ssg.sh"
LOCKDIR="${SCRIPT_DIR}/.ssg.lock"
LOCK_PID_FILE="${LOCKDIR}/pid"

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
fi

if ! command -v pgrep >/dev/null 2>&1; then
  echo "ERROR: pgrep not found. (Expected at /usr/bin/pgrep on macOS.)"
  exit 1
fi

have_lsof=false
if command -v lsof >/dev/null 2>&1; then
  have_lsof=true
fi

echo "🔎🤠 Looking for running ssg.sh instances for:"
echo "    $SSG_PATH"

is_in_repo() {
  # Returns 0 if pid's CWD is this repo (best-effort); 1 otherwise.
  local pid="$1"
  if [ "$have_lsof" = true ]; then
    cwd="$(
      lsof -a -p "$pid" -d cwd -Fn 2>/dev/null \
        | sed -n 's/^n//p' \
        | head -n 1
    )"
    [ "${cwd:-}" = "$SCRIPT_DIR" ]
    return
  fi
  return 1
}

is_ssg_cmd() {
  # Returns 0 if pid looks like an ssg.sh invocation (absolute or relative); 1 otherwise.
  local pid="$1"
  cmd="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  echo "$cmd" | grep -Eq '(^|[[:space:]])(\./)?ssg\.sh([[:space:]]|$)|'"$(printf '%s' "$SSG_PATH" | sed 's/[.[\\*^$(){}+?|]/\\&/g')" || return 1
  return 0
}

candidate=""

# 1) Prefer lock pid if present (newer ssg.sh instances)
if [ -f "$LOCK_PID_FILE" ]; then
  lock_pid="$(cat "$LOCK_PID_FILE" 2>/dev/null || true)"
  if [ -n "${lock_pid:-}" ] && kill -0 "$lock_pid" 2>/dev/null; then
    candidate="$candidate $lock_pid"
  fi
fi

# 2) Find any ssg.sh processes (covers older / relative invocations)
# BSD pgrep's regex/ERE support is inconsistent across flags, so keep it simple here.
raw="$(pgrep -f 'ssg\.sh' 2>/dev/null || true)"
if [ -n "${raw:-}" ]; then
  candidate="$candidate $raw"
fi

# Filter + dedupe
pids=""
for pid in $candidate; do
  case " $pids " in
    *" $pid "*) continue ;;
  esac
  if is_ssg_cmd "$pid"; then
    # If we can, ensure it belongs to THIS repo (cwd filter). If lsof isn't available, accept.
    if [ "$have_lsof" = false ] || is_in_repo "$pid"; then
      pids="$pids $pid"
    fi
  fi
done
pids="${pids#" "}"

if [ -z "${pids:-}" ]; then
  echo "✅ No running ssg.sh processes found."
  # Clear stale lock if present.
  if [ -d "$LOCKDIR" ]; then
    echo "🧹🤠 Removing stale lock: $LOCKDIR"
    $DRY_RUN || rm -rf "$LOCKDIR"
  fi
  exit 0
fi

echo "🎯 Found PID(s): $pids"

collect_tree_pids() {
  # Prints a whitespace-delimited list of PIDs including $1 and all descendants.
  local root="$1"
  local queue=("$root")
  local seen=" $root "

  while [ "${#queue[@]}" -gt 0 ]; do
    local current="${queue[0]}"
    queue=("${queue[@]:1}")

    local kids
    kids="$(pgrep -P "$current" 2>/dev/null || true)"
    if [ -n "${kids:-}" ]; then
      local kid
      for kid in $kids; do
        case "$seen" in
          *" $kid "*) ;;
          *)
            seen="${seen}${kid} "
            queue+=("$kid")
            ;;
        esac
      done
    fi
  done

  # Trim leading/trailing spaces
  echo "${seen#" "}"
}

reverse_pids() {
  # Reverse a whitespace-delimited pid list.
  local list="$1"
  local out=""
  local pid
  for pid in $list; do
    out="$pid ${out}"
  done
  echo "$out"
}

all_tree_pids=""
for pid in $pids; do
  tree="$(collect_tree_pids "$pid")"
  all_tree_pids="${all_tree_pids} ${tree}"
done

# Dedupe (preserve first-seen order).
unique=""
for pid in $all_tree_pids; do
  case " $unique " in
    *" $pid "*) ;;
    *) unique="$unique $pid" ;;
  esac
done
unique="${unique#" "}"

echo "📋 Process tree PIDs to terminate (including children):"
ps -o pid= -o ppid= -o pgid= -o command= -p $unique 2>/dev/null | sed 's/^/    /' || true

kill_list="$(reverse_pids "$unique")"

if [ "$DRY_RUN" = true ]; then
  echo "🧪 DRY RUN: would send TERM then KILL (if needed), children-first."
else
  echo "🛑 Sending TERM (children first)..."
fi
for pid in $kill_list; do
  if [ "$DRY_RUN" = true ]; then
    echo "    would TERM $pid"
  else
    echo "    TERM $pid"
  fi
  $DRY_RUN || kill -TERM "$pid" 2>/dev/null || true
done

if [ "$DRY_RUN" = true ]; then
  # Don't report "survivors" in dry-run mode since nothing was actually signaled.
  if [ -d "$LOCKDIR" ]; then
    echo "🧪 DRY RUN: would remove lock: $LOCKDIR"
  fi
  exit 0
fi

sleep 0.8

echo "🔍 Checking for survivors..."
survivors=""
for pid in $unique; do
  if kill -0 "$pid" 2>/dev/null; then
    survivors="$survivors $pid"
  fi
done
survivors="${survivors#" "}"

if [ -n "${survivors:-}" ]; then
  echo "🧨 Still running after TERM: $survivors"
  echo "💀 Sending KILL (children first)..."
  kill_survivors="$(reverse_pids "$survivors")"
  for pid in $kill_survivors; do
    echo "    KILL $pid"
    $DRY_RUN || kill -KILL "$pid" 2>/dev/null || true
  done
else
  echo "✅ All ssg.sh processes (and children) terminated."
fi

# Remove lock directory if it remains.
if [ -d "$LOCKDIR" ]; then
  echo "🧹🤠 Removing lock: $LOCKDIR"
  $DRY_RUN || rm -rf "$LOCKDIR"
fi


