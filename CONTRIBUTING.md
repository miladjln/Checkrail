# Contributing to Agent Opt

Thank you for your interest in contributing to **Agent Opt**! This project enforces strict governance, security, and quality standards for AI agent orchestration and development workflows.

---

## 🛠️ Development Workflow

1. **Prerequisites**:
   - Bash 4.4+
   - Git 2.30+
   - Python 3.12+ (optional locally for static QA; required in CI)
   - Gitleaks (optional locally; fallback heuristic regex is used if absent)

2. **Verify Environment**:
   Run the doctor script to verify tool installations and repository integrity:
   ```bash
   bash scripts/doctor.sh
   ```

3. **Making Changes**:
   - Keep diffs surgical and focused.
   - If you add, delete, or rename files, record their purpose in `scripts/file-descriptions.txt`.
   - Synchronize the file documentation index:
     ```bash
     bash scripts/sync-docs.sh
     git add docs/file-index.md
     ```

4. **Running Quality Gates**:
   Before committing, run the test and lint harness:
   ```bash
   bash scripts/quality-gates.sh
   ```

---

## 🛡️ Guardrails & Protected Files

Certain files are protected against accidental modifications by autonomous agents (e.g. `AGENTS.md`, `kilo.jsonc`, `scripts/quality-gates.sh`, `scripts/doctor.sh`, `scripts/sync-docs.sh`).

If you are intentionally updating a protected file as a maintainer:
```bash
bash scripts/quality-gates.sh --allow-guardrail
SKIP=kilo-quality-gates git commit -m "your commit message"
```

---

## 📜 Code of Conduct & Standards

- Adhere to semantic versioning and clear commit messages.
- Ensure zero secrets or private credentials are included in any commit.
- Keep documentation clean and synchronized at all times.
