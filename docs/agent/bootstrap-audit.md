# Bootstrap Audit Findings & Fixes (F-01..F-24)

This document records every finding from the hardened-bootstrap audit and how
each was verified (pytest run, scratch-repo smoke tests, `bash -n` syntax
checks). Referenced from the bootstrap script header, `docs/agent/SUMMARY.md`,
and `docs/agent/protocol.md`.

| ID | Finding | Fix |
|----|---------|-----|
| F-01 | `scripts/sync-docs.sh` crashed on an unset `REPO_ROOT` because it is executed as a separate child process and never inherits an unexported variable from the parent bootstrap. | `REPO_ROOT` is now assigned locally, immediately after `cd`, inside the script itself. |
| F-02 | `scripts/quality-gates.sh` used Bash-4-only `declare -A`, breaking on macOS's default Bash 3.2. | Rewritten to avoid associative arrays entirely (plain `case` statements / functions). |
| F-03 | The `DLQTransport` contract assumed `send()` always returns a strict Python `bool`, but real boto3 SQS/SNS clients return a response dict. | `_is_successful_response()` now normalizes bool, `None`, and boto3-style dict responses (`ResponseMetadata.HTTPStatusCode`, `MessageId`, `SequenceNumber`, `success`). |
| F-04 | Deleting a committed `.tfvars` file was rejected by Gate 5. | The tfvars check now uses diff-filter `ACMR` (Added/Copied/Modified/Renamed), excluding `D` (deleted). |
| F-05 | `route_id` sanitization was an incomplete deny-list. | Replaced with a strict allow-list regex (`^[A-Za-z0-9_.:-]{1,64}$`), validated against the raw (unstripped) string. |
| F-06 | Timestamps had no plausibility bounds. | Added a ±24h past / +5min future skew window relative to a reference time. |
| F-07 | CI silently allowed brand-new protected files to be introduced without any human review. | New protected files now require an explicit `NEW_GUARDRAIL_INTRODUCTION_ACK=true` admin acknowledgement; modifications to *existing* protected files are always blocked. |
| F-08 | Scope collection silently fell back to an unscoped `git diff` if `BASE_REF` could not be classified. | `collect_scoped_files()` now fails closed (`exit 1`) when the base ref resolves to an unsupported git object type. |
| F-09 | Raw ingest records could end up in logs. | Only a redacted preview (`_redact_record_for_log`) is ever printed; full records only flow to the DLQ transport. |
| F-10 | The path-traversal check rejected any path merely containing the substring `..` (e.g. `file..name.txt`). | Traversal is now checked per path *segment*, not by substring match. |
| F-11 | TOCTOU window between existence check and file write. | A final existence/symlink re-check runs immediately before `mv` in `safe_write`/`safe_write_strict`. |
| F-12 | The bootstrap's own `mktemp` scratch files (`.tmp.*`) were not gitignored, so an interrupted run could leave an untracked file that fails Gate 2. | `.gitignore` now includes `.tmp.*`. |
| F-13 | `overwrite_write()` never checked whether the existing target was a symlink before clobbering it. | It now refuses to overwrite a symlink or non-regular file target. |
| F-14 | Gate 0 unconditionally required all four pinned tools to be installed, even when a run touched no relevant files. | Tool-version checks are now lazy, invoked only by the gate that actually needs the tool. |
| F-15 | Content comparisons materialized a second temp file for every single comparison. | Comparisons now use process substitution (`cmp -s target <(...)`). |
| F-16 | Protected-pattern scanning issued one `git diff` invocation per pattern (13+ calls). | `collect_scoped_files()` now combines all patterns into a single `git diff` call. |
| F-17 | CI re-downloaded pip packages, Terraform plugins, and pinned tool archives on every run. | CI now caches pip (`actions/setup-python` cache), the Terraform plugin cache dir, and the tflint/gitleaks download archives. |
| F-18 | Contract tests didn't cover non-dict / float / `None` input types. | Added `test_non_dict_record_rejected`, `test_none_record_rejected`, `test_non_integer_delay_types_rejected`. |
| F-19 | Contract tests didn't cover the timestamp plausibility window. | Added past/future boundary and over-limit tests. |
| F-20 | Quarantine tests didn't cover boto3/SQS/SNS-style DLQ responses. | Added SQS/SNS-style response tests plus an HTTP-error-status test. |
| F-21 | SHA-pinned GitHub Actions in `ci.yml` would silently go stale. | Added `.github/dependabot.yml` for weekly `github-actions` updates. |
| F-22 | Tool-version checks required an exact byte-for-byte match, breaking on any routine patch release. | Checks now require the same major.minor and patch `>=` the pinned minimum. |
| F-23 | This very file (`docs/agent/bootstrap-audit.md`) was referenced everywhere but never actually created by the bootstrap script. | The bootstrap now writes this file. |
| F-24 | `BOOTSTRAP_TOUCHED_FILES` was dereferenced with bare `"${BOOTSTRAP_TOUCHED_FILES[@]}"` / `"${BOOTSTRAP_TOUCHED_FILES[*]}"` in `append_if_missing()` and the final staging loop. On Bash < 4.4 (e.g. macOS's Bash 3.2) with `set -u`, expanding an empty array this way raises `unbound variable`, crashing an idempotent re-run where no new file was created. | Both sites now use the same `"${arr[@]:-}"` / `"${arr[*]:-}"` guard already used for `GLOBAL_TMP_FILES` in `cleanup_tmp_files()`. |

## Verification methodology
- `bash -n scripts/*.sh` for syntax validation.
- `pytest tests/ -v` for full contract coverage (schema + quarantine).
- Scratch-repo smoke tests: fresh clone bootstrap, idempotent re-run bootstrap
  (empty-touched-files path), and a simulated PR introducing/tampering with a
  protected file.