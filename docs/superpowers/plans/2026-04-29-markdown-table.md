# Markdown Table Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `vit` support for selecting the Markdown pipe table containing the cursor.

**Architecture:** Follow the existing plugin structure: `lua/kontur/module.lua` owns boundary detection and visual line selection, while `lua/kontur.lua` exposes the public wrapper and keymap configuration. A lightweight headless Neovim Lua test script verifies behavior because the repo has no current automated test harness.

**Tech Stack:** Lua, Neovim headless runtime, Vim help docs.

---

### Task 1: Markdown Table Selector

**Files:**
- Create: `tests/markdown_table_spec.lua`
- Modify: `lua/kontur/module.lua`
- Modify: `lua/kontur.lua`
- Modify: `README.md`
- Modify: `doc/kontur-docs.txt`

- [x] **Step 1: Write the failing test**

Create `tests/markdown_table_spec.lua` with assertions that direct calls to `require("kontur.module").select_markdown_table()` select lines 2 through 5 when the cursor is on the header, delimiter, or body row of this table:

```markdown
before
| Name | Align | Count |
| --- | :---: | ---: |
| Ada | mid | 1 |
| Linus | low | 2 |
after
```

Also assert that a non-table line containing `|` leaves the cursor in normal mode.

- [x] **Step 2: Run test to verify it fails**

Run: `/opt/homebrew/bin/nvim --headless -u NONE "+set rtp+=." "+lua dofile('tests/markdown_table_spec.lua')" +qa`

Expected: FAIL because `select_markdown_table` is not defined.

- [x] **Step 3: Write minimal implementation**

Add helper functions in `lua/kontur/module.lua` for pipe-row detection, delimiter-row detection, table range discovery, and visual line selection. Export `M.select_markdown_table`.

- [x] **Step 4: Wire the public API and mapping**

Add `table_object_char = "t"` to `lua/kontur.lua`, register `i{table_object_char}` in visual and operator-pending modes, and expose `M.select_markdown_table()`.

- [x] **Step 5: Update documentation**

Document `table_object_char`, `vit`, and the Markdown table example in `README.md` and `doc/kontur-docs.txt`.

- [x] **Step 6: Verify**

Run:

```bash
/opt/homebrew/bin/nvim --headless -u NONE "+set rtp+=." "+lua dofile('tests/markdown_table_spec.lua')" +qa
/opt/homebrew/bin/stylua lua plugin tests
/opt/homebrew/bin/nvim --headless "+lua require('kontur').setup({})" +qa
/opt/homebrew/bin/nvim -u NONE "+set rtp+=." "+help kontur" +qa
```

Expected: test and smoke commands pass; formatting exits successfully.
