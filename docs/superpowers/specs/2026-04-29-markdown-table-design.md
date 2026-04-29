# Markdown Table Selection Design

## Goal
Add a Markdown table text object that selects the whole pipe-style table containing the cursor.

## Decision
Add an independent table text object on `it`, configurable through `table_object_char`. Keep table behavior separate from repeatable prefix selection so existing `ir` semantics do not change.

## Behavior
- `it`: selects the Markdown pipe table containing the cursor.
- The selector works when the cursor is on the header row, delimiter row, or any body row.
- A valid table must include a delimiter row such as `| --- | :---: | ---: |`.
- The selection starts at the header row immediately above the delimiter and ends at the last contiguous pipe row below it.
- If the cursor is not inside a valid Markdown pipe table, no selection is made.

## Implementation Notes
- Add Markdown table range detection in `lua/kontur/module.lua`.
- Expose `select_markdown_table()` through `lua/kontur.lua`.
- Register `i{table_object_char}` in operator-pending and visual modes.
- Add headless Neovim coverage for header, delimiter, body-row, and non-table cursor positions.
- Update `README.md` and `doc/kontur-docs.txt` with configuration and usage examples.
