<div align="center">

# 🛡️ AgentGuard

### Deterministic Governance, Security Guardrails & Token-Optimized Quality Gates for Autonomous AI Coding Agents

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI / Quality Gates](https://github.com/miladjln/agent-guard/actions/workflows/quality-gates.yml/badge.svg)](https://github.com/miladjln/agent-guard/actions)
[![Bash 4.4+](https://img.shields.io/badge/Bash-4.4%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Python 3.12+](https://img.shields.io/badge/Python-3.12%2B-blue.svg)](https://www.python.org/)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks-brightgreen.svg)](https://github.com/gitleaks/gitleaks)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

*An enterprise-grade, academically grounded framework for deterministic orchestrations, token-efficient context hierarchies, and automated multi-tier security verification for LLM-based autonomous software engineering.*

</div>

---

## 🔬 Scientific & Industrial Rationale

As Large Language Models (LLMs) and autonomous agent frameworks (**Kilo**, **Claude Code**, **OpenCode**, **Cursor**, **Devin**) transition from exploratory code-completion to fully autonomous codebase refactoring and CI/CD operations, they introduce critical failure modes:

1. **Context Bloat & Token Degradation (Attention Bleed)**: Recursive file-tree scanning and unfiltered context dumps exhaust attention mechanisms, increasing operational latency, API costs, and hallucination rates.
2. **Guardrail & Security Erosion**: Unconstrained agents inadvertently modify security manifests, weaken CI checks, or bypass permission boundaries.
3. **Secret Ingestion & Exfiltration**: Accidental ingestion and staging of `.env` files, SSH credentials, and private keys.
4. **Repository Documentation Drift**: Autonomous changes break manual architectural maps, invalidating agent grounding on subsequent turns.
5. **Session Amnesia & State Loss**: Fragmented state transitions between multi-turn or multi-agent worktree handovers.

**AgentGuard** introduces a **multi-tiered, deterministic verification and context-management harness** that enforces formal safety boundaries, minimizes token overhead by up to ~75%, and guarantees cryptographic and architectural compliance before code reaches review.

---

## 🏛️ Architectural Taxonomy & Core Pillars

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Layer 0: AGENTS.md (Root Invariants)                  │
│           Deterministic trigger routing • Zero token wastage • Lean L0      │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                ▼                                             ▼
┌───────────────────────────────┐             ┌───────────────────────────────┐
│   Layer 1: Architecture Core  │             │   Layer 2: Protocol Engine    │
│    (docs/agent/SUMMARY.md)    │             │   (docs/agent/protocol.md)    │
│  Domain context, Stack & Flow │             │   Deep workflows & fallback   │
└───────────────────────────────┘             └───────────────────────────────┘
                                       │
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                    Automated Governance & Verification Harness              │
│  ├── 8-Tier Quality Verification (scripts/quality-gates.sh)                 │
│  ├── Zero-Drift Compact Indexing (scripts/sync-docs.sh)                     │
│  ├── Sandboxed Permission Rules (kilo.jsonc)                                │
│  ├── Formal Empirical Audit Matrix (docs/agent/bootstrap-audit.md)          │
│  └── Deterministic State Handover (docs/agent/HANDOVER.md)                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1. ⚡ Hierarchical Context Minimization
AgentGuard discards monolithic prompts in favor of an indexed 3-layer architecture:
- **Layer 0 (`AGENTS.md`)**: Always-on routing table. Directs agents to exact files without recursive exploration.
- **Layer 1 (`docs/agent/SUMMARY.md`)**: High-level domain, stack specifications, and pipeline models.
- **Layer 2 (`docs/agent/protocol.md`)**: Deep execution workflows, loaded strictly when blocking ambiguities arise.

### 2. 🛡️ 8-Tier Quality Verification Gates (`scripts/quality-gates.sh`)
Every agent and developer change is passed through an unyielding 8-tier verification pipeline:
* **Gate 0: Tooling Prerequisite Check** — Verifies major/minor version compliance (`.tool-versions`).
* **Gate 1: Base Branch & Differential Scoping** — Isolates target diffs and prevents unanchored commits.
* **Gate 2: Clean Tree & Working-Copy Integrity** — Validates staging consistency and rejects untracked drift.
* **Gate 3: Protected Guardrail Defense** — Blocks agent mutations to security, CI, and policy files unless explicitly authorized with `--allow-guardrail`.
* **Gate 4: Shell Syntax & POSIX/LF Compliance** — Strict `bash -n` validation and line-ending verification.
* **Gate 5: Static Analysis & Code Quality** — Python static typing, linting (`ruff`), and QA harnesses.
* **Gate 6: Infrastructure & Configuration Verification** — Validates Terraform and cloud orchestration manifests.
* **Gate 7: Deterministic Documentation Verification** — Fails if documentation index (`docs/file-index.md`) drifts from disk state.
* **Gate 8: Anti-Leak Cryptographic & Secret Scan** — Integrated Gitleaks analysis and fallback heuristic scanning.

### 3. 📑 Zero-Drift Repository Indexing (`scripts/sync-docs.sh`)
- Generates a compact, deterministic inventory in `docs/file-index.md` from `scripts/file-descriptions.txt`.
- Provides complete structural grounding to agents within a bounded token budget ($\le 20\text{ KB}$).

### 4. 🔒 Engine Sandbox & Permission Map (`kilo.jsonc`)
- Strict deny/ask rules for destructive actions (`rm -rf`, raw `.env` reading, unconstrained shell execution).

### 5. 🔄 Bounded State Handover Protocol (`docs/agent/HANDOVER.md`)
- Bounded 40-line invariant state schema (`[TASK]`, `[DIFF_SUMMARY]`, `[GATES_STATUS]`, `[NEXT]`, `[BLOCKERS]`) providing continuous context across distributed worktrees and agent sessions.

---

## 📊 Empirical Verification & Audit (F-01 to F-24)

AgentGuard incorporates an empirical test suite and failure-mode analysis documented in [`docs/agent/bootstrap-audit.md`](docs/agent/bootstrap-audit.md), addressing 24 critical real-world edge cases including:
- Subshell environment isolation and memory leaks.
- Cross-platform POSIX compatibility (Bash 3.2+ fallback to 4.4+).
- Symlink traversal attack prevention in documentation generators.
- TOCTOU (Time-of-Check to Time-of-Use) atomic file operations.
- Windows execution alias stub handling in CI environments.

---

## 🚀 Quick Start

### 1. Installation & Environment Verification
```bash
git clone https://github.com/miladjln/agent-guard.git
cd agent-guard

# Run full diagnostic verification
bash scripts/doctor.sh
```

### 2. Pre-Commit Integration
```bash
# Register quality gates into local git hooks
pre-commit install
```

### 3. Documentation Synchronization
Whenever repository files or modules change:
```bash
# Update descriptions in scripts/file-descriptions.txt, then:
bash scripts/sync-docs.sh
git add docs/file-index.md
```

### 4. Quality Gate Execution
```bash
# Fast-tier gate for staged changes (Pre-Commit)
bash scripts/quality-gates.sh --staged-only --fast

# Complete 8-tier verification suite (CI Equivalent)
bash scripts/quality-gates.sh
```

---

## 🛠️ Script Harness Reference

| Script | Function | Key Flags |
|---|---|---|
| `scripts/doctor.sh` | Health check for environment, dependencies, CRLF, and pack integrity. | None |
| `scripts/quality-gates.sh` | Comprehensive 8-tier automated quality and security gates. | `--staged-only`, `--fast`, `--allow-guardrail`, `--strict-versions` |
| `scripts/sync-docs.sh` | Deterministic documentation indexer and drift detector. | `--check`, `--compact`, `--full` |

---

## 📂 Repository Topology

```text
agent-guard/
├── .github/
│   ├── workflows/
│   │   └── quality-gates.yml       # Production CI Verification Pipeline
│   ├── ISSUE_TEMPLATE/             # Standardized Bug & Feature Blueprints
│   ├── PULL_REQUEST_TEMPLATE.md    # Gate-Enforced Pull Request Checklist
│   ├── dependabot.yml              # Automated Dependency & Action Updates
│   └── CODEOWNERS                  # Access & Ownership Matrix
├── .kilo/                          # Autonomous Agent Workspace & Subagent Runtime
├── docs/
│   ├── agent/
│   │   ├── SUMMARY.md              # Layer 1 Architectural Context
│   │   ├── protocol.md             # Layer 2 Execution Protocol
│   │   ├── HANDOVER.md             # Standardized State Handover File
│   │   └── bootstrap-audit.md      # Formal Security & Regression Audit Log
│   └── file-index.md               # Auto-Generated Compact File Inventory
├── scripts/
│   ├── doctor.sh                   # Environment Diagnostic & Health Script
│   ├── file-descriptions.txt       # Canonical File Description Register
│   ├── quality-gates.sh            # 8-Tier Security & Quality Gate Harness
│   └── sync-docs.sh                # Zero-Drift Documentation Synchronizer
├── .gitattributes                  # LF Enforcement & Normalization Policy
├── .gitignore                      # Comprehensive VCS Ignore Register
├── .kilocodeignore                 # LLM Context Exclusion Filter
├── .pre-commit-config.yaml         # Pre-commit Hook Hookpack Configuration
├── .tool-versions                  # Pinned Tool Runtime Versions
├── AGENTS.md                       # Layer 0 Root Agent Rulebook & Invariants
├── CITATION.cff                    # Formal Academic Citation Metadata
├── CONTRIBUTING.md                 # Engineering & Contribution Guidelines
├── kilo.jsonc                      # Engine Security Sandbox & Permissions
├── LICENSE                         # MIT Open-Source License
├── README.md                       # Comprehensive Technical Specification
└── SECURITY.md                     # Security Vulnerability & Disclosure Policy
```

---

## 📑 Citation & Academic Reference

If you incorporate **AgentGuard** in academic papers, research benchmarks, or industrial autonomous frameworks, please cite:

```bibtex
@software{jalilian2026agentguard,
  author = {Jalilian, Seyed Milad},
  title = {AgentGuard: Deterministic Governance, Security Guardrails and Token Optimization for Autonomous AI Coding Agents},
  year = {2026},
  url = {https://github.com/miladjln/agent-guard},
  version = {1.0.0}
}
```

---

## 🤝 Contributing

We welcome contributions from engineers and researchers. Please review [CONTRIBUTING.md](CONTRIBUTING.md) for workflow protocols and gate standards.

---

## 🛡️ Security

For vulnerability disclosures and security policies, refer to [SECURITY.md](SECURITY.md).

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file.

Copyright (c) 2026 **Seyed Milad Jalilian**
