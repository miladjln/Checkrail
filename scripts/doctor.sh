#!/usr/bin/env bash
set -euo pipefail

if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
    for b in /opt/homebrew/bin/bash /usr/local/bin/bash; do
        [[ -x "$b" ]] && exec "$b" "$0" "$@"
    done
    echo "ERROR: Bash 4.4+ required" >&2; exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: doctor.sh must be run inside a Git repository." >&2
    exit 1
fi
cd "$(git rev-parse --show-toplevel)"

echo "Bash: ${BASH_VERSION}"
echo "Git: $(git --version)"
if command -v gitleaks >/dev/null 2>&1; then
    echo "Gitleaks: $(gitleaks version 2>/dev/null || echo present)"
else
    echo "Gitleaks: NOT FOUND (fallback regex will be used locally)"
fi
if command -v ruff >/dev/null 2>&1; then
    echo "Ruff: $(ruff --version 2>/dev/null || echo present)"
else
    echo "Ruff: NOT FOUND (Gate 5 skips Python static checks when .py files change)"
fi
if command -v terraform >/dev/null 2>&1; then
    tfv="$(terraform version 2>/dev/null)" || tfv="present"
    echo "Terraform: ${tfv%%$'\n'*}"
else
    echo "Terraform: NOT FOUND (Gate 6 only runs when .tf files change)"
fi

# Python: detect a FUNCTIONAL interpreter. `command -v python3` can succeed on
# Windows while resolving to a non-functional "App execution alias" stub (the
# exact cause of quality-gates.sh crashing with exit 49). Probe for real
# execution and fall back to plain `python` (the real Windows install name).
# Reported for visibility only; Python is optional locally (Gate 3 skips
# semantic checks gracefully when absent), required in CI.
PY_OK=""
PY_VER=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1 && "$cand" -c 'import sys' >/dev/null 2>&1; then
        PY_OK="$cand"
        PY_VER="$("$cand" --version 2>&1)"
        break
    fi
done
if [[ -n "$PY_OK" ]]; then
    echo "Python: ${PY_VER} (${PY_OK})"
else
    if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
        echo "Python: NOT FUNCTIONAL — a python/python3 resolves to a non-functional stub (e.g. Windows App Execution Alias); Gate 3 semantic checks will be skipped"
    else
        echo "Python: NOT FOUND (Gate 3 semantic checks will be skipped locally; required in CI)"
    fi
fi

need=(AGENTS.md kilo.jsonc .kilocodeignore .gitattributes .pre-commit-config.yaml
      .tool-versions .vscode/extensions.json .vscode/settings.json
      .github/CODEOWNERS .github/workflows/quality-gates.yml
      docs/agent/SUMMARY.md docs/agent/protocol.md docs/agent/HANDOVER.md
      docs/file-index.md
      scripts/sync-docs.sh scripts/quality-gates.sh scripts/file-descriptions.txt scripts/doctor.sh)
miss=0

for f in "${need[@]}"; do
    if [[ ! -f "$f" ]]; then echo "MISSING $f"; miss=1; fi
    if [[ -L "$f" ]]; then echo "SYMLINK $f"; miss=1; fi
done

# A symlinked scripts/ or docs/ directory would let MAP_FILE / OUT_FILE resolve
# through an attacker-controlled tree that the per-file symlink checks in
# sync-docs.sh do not catch (they test the leaf file, not the parent dir).
for d in scripts docs .github .vscode .circleci .kilo; do
    if [[ -L "$d" ]]; then echo "SYMLINK $d (pack directory must be real)"; miss=1; fi
done

if [[ -f .kiloignore ]]; then
    echo "WRONG NAME .kiloignore (use .kilocodeignore)"; miss=1
fi

# CRLF detection, bash-native (portable; no grep-dialect dependence). Only
# the pack scripts, which are small enough to read whole.
for s in scripts/sync-docs.sh scripts/quality-gates.sh scripts/doctor.sh; do
    [[ -f "$s" ]] || continue
    if [[ "$(<"$s")" == *$'\r'* ]]; then
        echo "CRLF detected in $s"; miss=1
    fi
done

# Syntax-check only existing pack scripts; collect failures, never abort early.
for s in scripts/sync-docs.sh scripts/quality-gates.sh scripts/doctor.sh; do
    [[ -f "$s" ]] || continue
    if ! bash -n "$s"; then
        echo "SYNTAX $s"; miss=1
    fi
done

if [[ -f scripts/sync-docs.sh ]]; then
    bash scripts/sync-docs.sh --check || miss=1
fi

echo "Doctor done (exit=$miss)"
exit "$miss"
