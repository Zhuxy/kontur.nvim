# Repository Guidelines

## Project Structure & Module Organization
`kontur.nvim` is a small Neovim plugin with a standard Lua layout. Plugin entrypoints live in `plugin/` and `lua/`: `plugin/kontur.lua` is the runtime loader, `lua/kontur.lua` exposes `setup()` and public text objects, and `lua/kontur/module.lua` contains the selection logic. User-facing documentation lives in `README.md` and `doc/kontur-docs.txt`. Keep behavior changes and doc updates together when a feature affects keymaps or text-object semantics.

## Build, Test, and Development Commands
There is no build step. Use these commands during development:

- `stylua lua plugin`: format Lua sources using the repo’s `.stylua.toml`.
- `nvim --headless "+lua require('kontur').setup({})" +qa`: quick smoke test that the plugin loads without errors.
- `nvim -u NONE "+set rtp+=." "+help kontur" +qa`: verify the runtime path and Vim help entry after doc updates.

For interactive testing, open a sample buffer in Neovim and exercise `vii`, `vih`, `vip`, and `vit` against indented code, Markdown headings, prefix-based lists, and Markdown tables.

## Coding Style & Naming Conventions
Lua files use 2-space indentation, Unix line endings, and a 120-column target as defined in `.stylua.toml`. Prefer double quotes when practical and let `stylua` normalize details. Follow the existing module style: local helpers first, exported functions on `M`, and descriptive names such as `select_under_heading` or `get_prefix_pattern`. Keep the public API in `lua/kontur.lua` thin and place behavior-heavy logic in `lua/kontur/module.lua`.

## Testing Guidelines
This repository does not currently include an automated test suite. Every functional change should include a manual verification note covering the affected text object, cursor position, and expected visual selection. When fixing edge cases, add or update examples in `README.md` and `doc/kontur-docs.txt` so behavior stays documented.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commits with prefixes like `feat:`, `refactor:`, `docs:`, and `bug fix:`. Keep commits focused and describe the user-visible behavior change. Pull requests should summarize the scenario tested, mention any doc updates, and include before/after examples when selection behavior changes.
