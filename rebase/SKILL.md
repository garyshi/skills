---
description: Rebase the current Git branch onto a target branch, with upfront conflict analysis before touching history.
allowed-tools:
  - Bash(git remote:*)
  - Bash(git fetch:*)
  - Bash(git merge-base:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git show:*)
  - Bash(git status:*)
  - Bash(git add:*)
  - Bash(git rebase:*)
---

Rebase the current branch onto **$ARGUMENTS** (default: `origin/main`).

> **Branch name resolution:**
> - No argument → default to `origin/main` (fetch first).
> - `remote/branch` format (e.g. `origin/main`) → treated as a remote-tracking branch (fetch first).
> - Any other name → treated as a local branch as-is; do not substitute a remote.

---

## Step 1 — Fetch the target remote (if applicable)

If the target is in `remote/branch` format (e.g. `origin/main`), fetch it first so the rebase uses the latest upstream state:

```bash
git fetch <remote> <branch>
# e.g. git fetch origin main
```

---

## Step 2 — Find the merge-base

Identify the common ancestor of the current branch and the target:

```bash
git merge-base HEAD <target>
# example: git merge-base HEAD origin/main
```

Save this commit SHA as `<merge_base>` for use in subsequent steps.

---

## Step 3 — Identify files changed on each side

Determine which files diverged since the merge-base, on each branch independently:

```bash
# Files changed on the current branch
git diff --name-only <merge_base> HEAD

# Files changed on the target branch
git diff --name-only <merge_base> <target>
```

The **intersection** of these two lists is the set of files at risk for conflicts.

---

## Step 4 — Investigate renamed or deleted files on the target branch

For each file present in the current branch's diff but absent from the target branch tip, determine whether it was renamed or deleted upstream:

```bash
# Check per-commit history on target for renames or deletions
git log --follow --diff-filter=RD --summary <merge_base>..<target> -- <file>
```

- **Renamed**: the changes made on the current branch must be re-applied to the new filename.
- **Deleted**: no action is typically needed unless the current branch's changes should be preserved.

---

## Step 5 — Review divergent changes to conflicting files

For each file changed on both sides, inspect what each branch actually changed:

```bash
# What the target branch changed in this file since merge-base
git diff <merge_base>..<target> -- <file>

# What the current branch changed in this file since merge-base
git diff <merge_base>..HEAD -- <file>
```

Use `git show <commit>:<file>` to inspect a specific version if needed. Take note of the intent and scope of each side's changes before proceeding.

---

## Step 6 — Run the rebase

With a clear understanding of potential conflicts, start the rebase:

```bash
git rebase <target>
```

When conflicts arise:

1. Read `git status` to identify conflicted files.
2. Resolve each conflict using the understanding gained in Steps 4–5 — do not guess; apply the correct logical intent from each side.
3. Stage resolved files:
   ```bash
   git add <file>
   ```
4. Continue:
   ```bash
   git rebase --continue
   ```

To abort at any point:
```bash
git rebase --abort
```

---

## Reference: common conflict patterns

| Situation | Resolution approach |
|-----------|---------------------|
| Both branches edited the same function | Merge the changes logically; keep both intents if compatible |
| Target branch renamed a file | Apply current branch's diff to the new filename |
| Target branch deleted a file | Verify the deletion is intentional; skip if so |
| Import / dependency list conflicts | Union both sets, remove duplicates |
