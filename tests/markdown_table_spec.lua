vim.opt.runtimepath:append(".")
vim.opt.swapfile = false

local module = require("kontur.module")

local lines = {
  "before",
  "| Name | Align | Count |",
  "| --- | :---: | ---: |",
  "| Ada | mid | 1 |",
  "| Linus | low | 2 |",
  "after",
  "plain | pipe",
  "| A | B |",
  "| - | - |",
  "| 1 | 2 |",
}

local function reset_buffer()
  vim.cmd("enew!")
  vim.bo.swapfile = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modified = false
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.cmd("normal! gg")
end

local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)), 2)
  end
end

local function capture_selection(fn)
  local cursor_calls = {}
  local visual_started = false
  local original_set_cursor = vim.api.nvim_win_set_cursor
  local original_cmd = vim.cmd

  vim.api.nvim_win_set_cursor = function(window, position)
    table.insert(cursor_calls, position)
    return original_set_cursor(window, position)
  end

  vim.cmd = function(command)
    if command == "normal! V" then
      visual_started = true
    end
    return original_cmd(command)
  end

  local ok, err = pcall(fn)

  vim.api.nvim_win_set_cursor = original_set_cursor
  vim.cmd = original_cmd

  if not ok then
    error(err, 2)
  end

  return cursor_calls, visual_started
end

local function assert_table_selection(cursor_line)
  reset_buffer()
  vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })

  local cursor_calls, visual_started = capture_selection(function()
    module.select_markdown_table()
  end)

  assert_equal(visual_started, true, "table selection should start Visual-line selection")
  assert_equal(cursor_calls[1][1], 2, "selection should start at the table header")
  assert_equal(cursor_calls[2][1], 5, "selection should end at the final table row")
end

assert_table_selection(2)
assert_table_selection(3)
assert_table_selection(4)
assert_table_selection(5)

reset_buffer()
vim.api.nvim_win_set_cursor(0, { 7, 0 })
local cursor_calls, visual_started = capture_selection(function()
  module.select_markdown_table()
end)
assert_equal(visual_started, false, "non-table pipe line should not start Visual-line selection")
assert_equal(#cursor_calls, 0, "non-table pipe line should not move the cursor")

reset_buffer()
vim.api.nvim_win_set_cursor(0, { 9, 0 })
cursor_calls, visual_started = capture_selection(function()
  module.select_markdown_table()
end)
assert_equal(visual_started, false, "single-dash pipe rows should not count as Markdown table delimiters")
assert_equal(#cursor_calls, 0, "single-dash pipe rows should not move the cursor")

print("markdown table tests passed")
