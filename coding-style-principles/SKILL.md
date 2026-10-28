---
name: coding-style-principles
description: Coding style principles for naming, order of definitions, change scope, comments, error handling and reuse. Load before writing or modifying code. Run it directly for a style review, cleanup or refactor of given files or the current diff.
argument-hint: "[paths] [review|cleanup]"
metadata:
  version: "0.1.0"
---

# Coding Style Principles

These are principles, closer to craft and best practice than to strict rules. Follow them by default. Break one when following it would clearly make the code worse, and be able to say why. Where a project's own conventions (its agent instructions such as CLAUDE.md or AGENTS.md, linter config, the style of the surrounding code) differ, the project wins.

## Scope of a change

This applies to every principle below. Keep a change to what the task needs. When you notice code outside the task that falls short of these principles, mention it and leave it for a separate cleanup commit or PR. Don't mix unrelated renames, reordering, reformatting or refactors into an incremental change, so that its diff stays small and reviewable.

The exception is refactoring that the change itself needs, such as generalizing an existing helper so the change can reuse it (see Reuse).

## Naming

Name symbols (classes, functions, methods, variables, constants) properly and consistently.

* Functions and methods describe actions, so name them with verbs. Properties are the exception, meaning cheap accessors without side effects; a method that scans directories or reads files is not a property.
* Use verbs consistently across a codebase: the same verb for the same meaning, different verbs for different meanings.
* Classes, variables and constants are usually nouns, named at the proper level of abstraction. Don't give a general name to something specific in the codebase, e.g. `Record` for what is really an invoice line.
* Functions that share a verb must perform the same operation with the same effect. Their names then differ in the part that states the real difference between them (the input form, the target or the scope), not in overlapping nouns. E.g. take `import_file(path)` and `import_document(doc)`, where the file holds a document and both end up importing it: the real difference is the input form, so name them `import_from_path(path)` and `import_from_dict(doc)`.
* A function's contract is part of its name. If two functions do the same operation but differ in error behavior (raise vs. return or record failures), side effects or blocking, the name must show it, with one marker used consistently across the codebase. E.g. if `parse_date()` raises and `try_parse_date()` returns None, then a `parse_amount()` that also returns None on bad input breaks the convention: name it `try_parse_amount()`.
* A plural name is a collection. Name a count as one (`contract_count`, not `contracts`), and name a single item in the singular even when an API spells it otherwise.
* When a value's unit, scale or time zone isn't obvious, put it in the name (`timeout_s`, `ts_ms`, `price_milli`) or use a type that carries it (aware datetimes, `timedelta`). This matters most when a project uses several units for the same kind of quantity (seconds and milliseconds, UTC and local time). A project that uses one unit throughout can treat it as the default and leave it unstated.

## Order of definitions

Order definitions in a file roughly by dependency: define a symbol before the code that uses it, so that reading top to bottom, most of what an implementation uses has already been seen. Follow this approximately; when strict order is impractical (mutual dependencies, a helper that needs the class it serves), don't contort the code for it. When adding code, place it where this order puts it, but don't reorder existing code just for this unless asked (see Scope of a change).

## Comments

* Add a "why" comment in most non-obvious places: the reason for a choice, a constraint, a pitfall, an alternative that doesn't work.
* A "what" comment earns its place where code is long or dense enough that what it does isn't apparent at a glance: a line summarizing a block, or a docstring for a tricky function. Don't restate code that already reads clearly.
* Never comment on the change itself ("added", "now uses", "fixed X"). That belongs in the commit message.
* When code changes, update or delete the comments and docstrings it invalidates.

## Error handling

Catch exceptions only where you can handle them meaningfully, and catch the narrowest types. Don't swallow errors or silently fall back to defaults; if a broad catch is intended (e.g. a boundary that must never raise), say why in a comment. Don't add checks for states the code guarantees can't happen. A broad catch can make the immediate run pass while hiding a real bug, and it is not a fix.

## Reuse

* Before writing a helper, look for an existing one in the codebase.
* Reuse when it makes sense at the level of abstraction, meaning the two uses are the same concept, not merely the same implementation. Two pieces of code that happen to compute the same thing but mean different things should stay separate, because they will change for different reasons.
* An existing helper may fit conceptually but sit in the wrong place or carry a name that is too narrow. Then move, rename or generalize it in the same commit or PR as the change that reuses it.
* Define each fact (a format, a limit, a mapping) in one place and derive the rest from it.

## Running as a review or cleanup

When invoked directly, or asked for a style review, cleanup or refactor:

1. **Target.** Use the paths given. Otherwise use the current branch's diff against its base. Ask if neither is clear.
2. **Read** each target file in full, and check how its symbols are used elsewhere (public vs. internal).
3. **Check systematically**, not by skimming:
   - List the functions and group them by verb and by marker (`try_`, `iter_`, `is_`, ...). Within each group, check for the same operation and contract, and check that the nouns state the real difference. Flag verb-less functions that do real work.
   - Vocabulary: one concept named by several words (e.g. "scaled" and "milli"), and one word used for several concepts in the same scope.
   - Nouns: level of abstraction, plural vs. count vs. single item, and units.
   - Order: symbols used before they are defined.
   - Comments: stale, describing the change, restating the obvious, or a "why" missing in a non-obvious place.
   - Reuse: duplicated logic or facts defined in several places, and helpers that should be generalized.
4. **Report** findings ranked by impact: misleading names and inconsistent vocabulary first, cosmetic ones last. Give each as `file:line`. Where breaking a principle is justified, say so instead of flagging it.
5. **Act** according to the request:
   - Review only: stop at the report.
   - Cleanup: apply the fixes as a dedicated change with behavior unchanged, and make sure tests and lint pass. Confirm before renaming public API (symbols used outside the module, documented, or called by other programs). List those renames in the report or PR description for the user to decide.
