---------------------------------------------------------
-- main function implementation here
---------------------------------------------------------

---@class NvimIndent
local M = {}


local is_blank_line = function(line)
  local line_content = vim.fn.getline(line)
  return line_content == nil or line_content:match("^%s*$")
end

M.select_indent = function()
  local current_line = vim.fn.line('.')
  if is_blank_line(current_line) then
    return
  end

  local start_indent = vim.fn.indent(current_line)
  if vim.v.count > 0 then
    start_indent = start_indent - vim.o.shiftwidth * (vim.v.count - 1)
    if start_indent < 0 then
      start_indent = 0
    end
  end

  -- Find the top line of the indented block
  local select_top = current_line
  while select_top > 1 and (is_blank_line(select_top - 1) or vim.fn.indent(select_top - 1) >= start_indent) do
    select_top = select_top - 1
  end

  -- Ensure we don't go before the first line
  if select_top < 1 then select_top = 1 end

  -- Find the bottom line of the indented block
  local select_bottom = current_line
  local last_line = vim.fn.line('$')
  while select_bottom < last_line and (is_blank_line(select_bottom + 1) or vim.fn.indent(select_bottom + 1) >= start_indent) do
    select_bottom = select_bottom + 1
  end

  if is_blank_line(select_bottom) then
    select_bottom = select_bottom - 1
  end

  -- Perform the selection
  vim.api.nvim_win_set_cursor(0, {select_top, 0})
  vim.cmd('normal! V')
  vim.api.nvim_win_set_cursor(0, {select_bottom, 0})
end

local function get_heading_level(line)
  local line_str = vim.fn.getline(line)
  if not line_str then return nil end
  local match = string.match(line_str, '^(#+)%s+.*$')
  return match and #match
end

local function find_governing_heading(start_line)
  local line = start_line
  while line > 0 do
    local level = get_heading_level(line)
    if level then
      return line, level
    end
    line = line - 1
  end
  return nil
end

local function find_next_heading(start_line, current_level)
  local line = start_line + 1
  local last_line = vim.fn.line('$')

  while line <= last_line do
    local next_level = get_heading_level(line)
    if next_level and next_level <= current_level then
      return line
    end
    line = line + 1
  end
  return nil
end

M.select_under_heading = function()
  local heading_line, heading_level = find_governing_heading(vim.fn.line('.'))

  if not heading_line then
    return
  end

  local select_top = heading_line + 1

  local next_heading_line = find_next_heading(heading_line, heading_level)
  local select_bottom

  if next_heading_line then
    select_bottom = next_heading_line - 1
  else
    select_bottom = vim.fn.line('$')
  end

  while select_bottom > select_top and is_blank_line(select_bottom) do
    select_bottom = select_bottom - 1
  end

  if select_top > select_bottom then return end

  -- Perform selection
  vim.api.nvim_win_set_cursor(0, {select_top, 0})
  vim.cmd('normal! V')
  vim.api.nvim_win_set_cursor(0, {select_bottom, 0})
end

local function get_prefix_pattern(line)
  local line_content = vim.fn.getline(line)
  if not line_content then return nil end

  -- Try to match a numbered list pattern (e.g., "1.", "12.")
  -- This pattern matches optional leading whitespace, then one or more digits, then a dot, then optional whitespace.
  local num_list_match = line_content:match("^%s*(%d+%.%s*)")
  if num_list_match then
    -- Return a pattern that matches any number followed by a dot and optional space at the beginning of the line
    return "^%s*%d+%.%s*"
  end

  -- Otherwise, get the first word as the literal prefix
  local literal_prefix = line_content:match("^%s*([^%s]+)")
  if not literal_prefix then return nil end

  -- Escape magic characters in the literal prefix for use as a pattern
  local escaped_prefix = literal_prefix:gsub("([%^$().%*+-?])", "%%%1")

  -- Return a pattern that matches optional leading whitespace, then the escaped literal prefix
  return "^%s*" .. escaped_prefix
end

M.select_prefix_block = function()
  local current_line = vim.fn.line('.')
  local pattern = get_prefix_pattern(current_line)

  if not pattern then
    return
  end

  local select_top = current_line
  while select_top > 1 do
    local prev_line_content = vim.fn.getline(select_top - 1)
    if prev_line_content and prev_line_content:match(pattern) then
      select_top = select_top - 1
    else
      break
    end
  end

  local select_bottom = current_line
  local last_line = vim.fn.line('$')

  while select_bottom < last_line do
    local next_line_content = vim.fn.getline(select_bottom + 1)
    if next_line_content and next_line_content:match(pattern) then
      select_bottom = select_bottom + 1
    else
      break
    end
  end

  vim.api.nvim_win_set_cursor(0, {select_top, 0})
  vim.cmd('normal! V')
  vim.api.nvim_win_set_cursor(0, {select_bottom, 0})
end

return M
