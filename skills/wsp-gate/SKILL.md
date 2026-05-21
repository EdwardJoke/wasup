---
name: wsp-gate
description: Pre-release security & production gate. Checks deps, secrets, test rate, memory patterns, deprecated APIs, unused code via CLIs/skills with generic fallback. The trigger is run gate, production check, security audit, is it ready to ship.
metadata:
  author: EdwardJoke
  version: 2.4.0
---

# wsp-gate — Pre-Release Quality Gate

A production-readiness scanner that runs after Review (Phase 4) but before Release (Phase 5) of the wsp-opt workflow. It detects problems that manual review misses — vulnerable dependencies, hardcoded secrets, test regressions, memory risks, deprecated APIs, and dead code.

If a critical check fails, the gate **blocks the release** by writing a `FAILED` report. If all checks pass, it writes a `PASSED` report and the release proceeds.

## Slot in the Workflow

```
wsp-opt Phase 4 (Review) ──► wsp-gate ──► wsp-opt Phase 5 (Tag & Merge)
                                      │
                                      ▼
                              .wasup/gates/vx.y.z.md
```

This skill is **self-contained** — it doesn't modify any existing SKILL.md files. It reads and writes only:
- **Reads**: `.wasup/wasup.toml` (gate config), filesystem (source files, lockfiles)
- **Writes**: `.wasup/gates/vx.y.z.md`

## Config

Add a `[gate]` section to `.wasup/wasup.toml`:

```toml
[gate]
enabled = true
checks = ["audit", "secrets", "test_rate", "memory_patterns", "deprecated_api", "no_use"]
fail_on = ["audit", "secrets", "deprecated_api"]
fallback_list = ["secrets", "deprecated_api"] # optional: force manual fallback path for listed checks
[gate.thresholds]
test_pass_rate = 100          # minimum % of tests passing
max_cves_critical = 0         # max critical CVEs allowed
max_cves_high = 0             # max high CVEs allowed
```

- **enabled**: toggle the gate on/off
- **checks**: which checks to run (see catalog below)
- **fail_on**: which checks, if they report any issue, cause the gate to `FAILED` and block release
- **fallback_list**: optional manual override list; checks in this list skip tier-1/tier-2 and run tier-3 fallback directly
- **thresholds**: numeric pass/fail boundaries

If no `[gate]` section exists or `enabled = false`, skip all checks and report "Gate skipped."

## Check Catalog

Each check follows a three-tier priority:

1. **Specialized skill** — if a skill exists for this check, delegate to it
2. **CLI tool** — run the dedicated CLI when installed
3. **Generic fallback** — use built-in analysis when nothing better is available

### `audit` — Dependency Vulnerability Scan

| Tier | Tool | Ecosystem |
|------|------|-----------|
| Skill | (future: `wsp-audit`) | — |
| CLI | `cargo audit` | Rust (Cargo.lock) |
| CLI | `npm audit` | Node (package-lock.json, yarn.lock) |
| CLI | `pip-audit` | Python (requirements.txt, Pipfile.lock) |
| CLI | `osv-scanner` | Universal (auto-detect from lockfiles) |
| Generic | Parse lockfile → check against local `advisory-db` or OSV API | Fallback if no CLI available |

**What it reports**: List of CVEs with severity, package, and fixed version. Also reports count per severity bucket.

**Fallback correctness rules**:
- Prefer lockfile-aware scanners (`cargo audit`, `npm audit`, `pip-audit`, `osv-scanner`) over ad-hoc queries.
- Never fail the gate on an unverified CVE match from a generic query alone.
- A CVE can block release only if it includes all of: package name, affected version in the repo, and severity (or CVSS) from the scanner/advisory response.
- If fallback data is incomplete, mark as `NEEDS_REVIEW` (warning), include evidence, and do not treat as fail_on by itself.

**Generic fallback query** (if no CLI and can't install):
```bash
# Use OSV API for each dependency in lockfile
curl -s "https://api.osv.dev/v1/query" -d '{"package": {"name": "serde", "ecosystem": "crates.io"}, "version": "1.0.0"}'
```

### `secrets` — Hardcoded Secrets Detection

| Tier | Tool | Scope |
|------|------|-------|
| Skill | (future: `wsp-secrets`) | — |
| CLI | `gitleaks` | Universal (git history + filesystem) |
| CLI | `trufflehog` | Universal |
| Generic | Pattern-based grep (see below) | Fallback |

**Generic fallback** — scan for common secret patterns in tracked files:
```bash
# Scan for sensitive patterns
grep -rnE '(?:password|secret|api.?key|token|auth.?token|private.?key)\s*[:=]\s*["'"'"'][^"'"'"']+["'"'"']' \
  --include='*.{rs,js,ts,py,go,java,kt,swift,yml,yaml,toml,json,env}' \
  . 2>/dev/null | grep -v 'node_modules\|target\|\.git' | head -50
```

Also scan for:
- `-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----`
- Base64 strings that look like tokens (>40 chars of `[A-Za-z0-9+/=]`)
- `.env` files committed to git

**What it reports**: File, line number, and the type of secret detected. If a path is a known false positive (e.g., test fixtures), report it separately.

**Fallback correctness rules**:
- Treat regex hits as **potential** secrets until verified.
- Verify with at least one additional signal before marking as confirmed:
  - entropy/format check (token-like shape), or
  - context check (not in docs/examples/tests), or
  - a second detector/tool finding the same line/path.
- Classify findings as:
  - `confirmed` (high confidence),
  - `needs_review` (medium confidence),
  - `likely_false_positive` (low confidence).
- Only `confirmed` findings should trigger fail_on behavior automatically.

### `test_rate` — Test Pass Percentage

| Tier | Tool | Ecosystem |
|------|------|-----------|
| Skill | (future: `wsp-test`) | — |
| CLI | Parse output of `cargo test`, `npm test`, `pytest`, `go test`, etc. | Universal |
| Generic | Ask the user what test command to run, execute it, parse summary | Fallback |

**How it works**:
1. Detect the project stack from lockfiles / config files (`Cargo.toml` → `cargo test`, `package.json` → `npm test`, etc.)
2. Run the test command
3. Parse the summary line from output. Common patterns to recognize:
   - `test result: ok. N passed; M failed` (Rust)
   - `Tests:       N passed, M total` (Jest)
   - `N passed, M failed in X.Ys` (pytest)
   - `ok / FAIL  N tests passed / M failed` (Go)
4. Calculate percentage = passed / (passed + failed) × 100
5. Compare against `[gate.thresholds].test_pass_rate`

**If parsing fails** (unrecognized output format): Present the raw test output to the user and ask them to confirm pass/fail.

**What it reports**: Pass count, fail count, total, percentage, and whether it meets the threshold.

### `memory_patterns` — Memory Risk Detection

| Tier | Tool | Scope |
|------|------|-------|
| Skill | (future: `wsp-memcheck`) | — |
| CLI | `valgrind` / `leaks -q` | Native binaries |
| Generic | Static pattern analysis | All languages |

**Generic fallback** — scan source for known dangerous patterns:

- **Rust**: `.unwrap()`, `.expect()`, `unsafe`, `std::mem::forget`, `Box::into_raw`, `ManuallyDrop`, cycle-prone `Rc` + `RefCell` combinations
- **Node/JS**: `process.on('unhandledRejection'`, unclosed `setInterval`/`setTimeout`, `new Promise` without `.catch()`
- **Python**: `except:`, `os.system()`, `eval()`/`exec()`, unclosed file handles
- **Go**: `defer` in loops, `goroutine` leaks, `panic` recovery

```bash
# Example: scan for Rust unwrap patterns with context
grep -rn '\.unwrap()' --include='*.rs' . 2>/dev/null | grep -v 'test\|#\[allow\|node_modules\|target'
```

**What it reports**: File, line number, pattern found, and severity. For valgrind/leaks, include the actual leak summary.

### `deprecated_api` — Deprecated API Usage

| Tier | Tool | Scope |
|------|------|-------|
| Skill | (future: `wsp-deprecation`) | — |
| CLI | Check project-specific deprecation config | — |
| Generic | Scan for known deprecated patterns | All languages |

**Generic fallback** — detect common deprecated APIs:

- **Rust**: `#\[deprecated\]` annotations in deps (check `cargo doc` or `cargo metadata` for deprecation warnings)
- In general: parse compiler/linter output for `deprecated` / `removed` warnings

The key approach: **run the build/lint command** and grep for `deprecated` / `removed` / `warning:` keywords in the stderr, then extract the relevant lines with file paths.

```bash
# Run build and capture deprecation warnings
cargo build 2>&1 | grep -i 'deprecated\|warning.*removed' | head -30
```

**What it reports**: File, line number, the deprecated API name, and suggested replacement (if available from the warning message).

**Fallback correctness rules**:
- Prefer compiler/linter-produced deprecation warnings over static string matching.
- Static pattern matches without compiler/linter evidence must be marked `needs_review`.
- Only warnings that include file path and symbol/API name should be considered `confirmed`.

### `no_use` — Unused Files / Modules

| Tier | Tool | Scope |
|------|------|-------|
| Skill | (future: `wsp-cleanup`) | — |
| CLI | `cargo udeps` (Rust), `depcheck` (Node) | Specific stacks |
| Generic | Git-based analysis | Universal |

**Generic fallback** — analyze git history and imports to find dead code:

1. **Unused files**: Cross-reference all `.rs`/`.js`/`.ts`/`.py` files against `mod`/`import`/`require` statements. Any file never referenced is likely dead.
2. **Dead exports**: Scan for exported/public items that are never imported anywhere else in the codebase.

```bash
# Find files committed but never imported
# Step 1: List all source files
find src/ -name '*.rs' | sort > /tmp/all_files.txt
# Step 2: Extract all mod/use references
grep -rE '^mod |^pub mod |^use |^pub use ' src/ --include='*.rs' | \
  sed 's/.*mod //;s/.*use //;s/::.*//;s/;//' | sort -u > /tmp/imported.txt
# Step 3: Diff (manual review recommended — false positives expected)
```

**What it reports**: List of potentially unused files/modules with confidence level (high / medium / low). Always note false positives.

## Execution Flow

```
1. Read .wasup/wasup.toml → get gate config
2. If !enabled → write "Gate skipped" report → exit
3. mkdir -p .wasup/gates
4. For each check in [gate].checks:
   a. If check is in [gate].fallback_list → run tier-3 directly and record `forced fallback (config)`
   b. Else attempt tier-1: dedicated skill → if available, delegate and collect result
   c. Else attempt tier-2: CLI → check if installed
      - If installed: run it and collect findings
      - If not installed: record `tool missing` warning and fall through to tier-3 automatically
   d. Fallback to tier-3: generic built-in analysis
5. Aggregate all check results
6. Determine gate verdict:
   - If any check in fail_on has **confirmed** findings → verdict = FAILED
   - Else → verdict = PASSED
7. Write gate report to .wasup/gates/vx.y.z.md
8. If FAILED → present report and stop (do not proceed to release)
9. If PASSED → present report and hand back control
```

## Report Format

Write `.wasup/gates/vx.y.z.md`:

```markdown
# Gate Report vx.y.z
**Date**: YYYY-MM-DD
**Verdict**: ✅ PASSED / ❌ FAILED

## Summary
- **audit**: ✅ 0 critical, 0 high CVEs
- **secrets**: ✅ No secrets found
- **test_rate**: ✅ 100% (142/142 passed)
- **memory_patterns**: ⚠️ 3 unwrap() calls (non-critical, waived)
- **deprecated_api**: ❌ 2 deprecated API usages found (fail_on)
- **no_use**: ✅ No unused files detected

## Detailed Findings

### audit — PASSED
Ran `cargo audit`. 0 vulnerabilities found.

### secrets — PASSED
Ran gitleaks (git scan). No secrets detected.

### test_rate — PASSED
Command: `cargo test`
Result: 142 passed, 0 failed, 0 ignored (100.0%)

### memory_patterns — WARNING
3 `.unwrap()` calls found (not in fail_on — informational only):
- `src/parser.rs:42` — `headers.unwrap()`
- `src/cache.rs:88` — `value.unwrap()`
- `src/cli.rs:15` — `arg.unwrap()`

### deprecated_api — FAILED ❌
2 usages found:
- `src/legacy.rs:23` — `old_http_client::connect()` (deprecated since v3.0, use `http_client::connect_v2()`)
- `src/utils.rs:56` — `temp_dir::new()` (removed in std 1.80, use `TempDir::new()`)

### no_use — PASSED
All files in `src/` are referenced in mod tree.

## Next Steps
[If FAILED] Fix the fail_on items above before releasing.
[If PASSED] Ready for Phase 5 — tag and release.
```

Present the verdict to the user:
> "Gate **PASSED** ✅ — all production checks clear. `.wasup/gates/vx.y.z.md` written. Ready for release."

Or if FAILED:
> "Gate **FAILED** ❌ — see `.wasup/gates/vx.y.z.md` for details. Fix the issues in `fail_on` and re-run the gate before releasing."

## Important Notes

- **No installs during gate run**: If a CLI tool is missing, do not install it during this workflow. Use fallback checks and record the tool as missing in the report.
- **Respect `.gitignore`**: Skip `node_modules/`, `target/`, `.git/`, `build/` in all file scans
- **False positives**: When using generic fallbacks, bias toward reporting *potential* issues and let the user decide. Never silently fail a gate on a false positive.
- **Confidence labels required**: For fallback security checks (`audit`, `secrets`, `deprecated_api`), label each finding as `confirmed`, `needs_review`, or `likely_false_positive`.
- **Speed**: Prefer CLI tools over generic fallbacks — they're faster and more accurate. Generic fallbacks are the last resort.
- **No side effects**: Never modify source code. Gate reads files, runs commands, writes reports — that's all.
