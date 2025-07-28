---------------------------------------------------------
-- main function implementation here
---------------------------------------------------------

---@class NvimIndent
local M = {}


local is_blank_line = function(line) return string.match(vim.fn.getline(line), '^%s*$') end

M.select_indent = function(around, include_last)
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

  if around then
    -- Move one line up to include the line before the block
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

    if around and include_last and (select_bottom + 1 <= last_line) and vim.fn.indent(select_bottom + 1) >= start_indent then
    select_bottom = select_bottom + 1
  end

  -- Adjust bottom line to not end on a blank line if not including last
  while not include_last and is_blank_line(select_bottom) do
    select_bottom = select_bottom - 1
  end

  -- Perform the selection
  vim.api.nvim_win_set_cursor(0, {select_top, 0})
  vim.cmd('normal! V')
  vim.api.nvim_win_set_cursor(0, {select_bottom, 0})
end

local function get_title_level(line)
  local line_str = vim.fn.getline(line)
  if not line_str then return nil end
  local match = string.match(line_str, '^(#+)%s+.*$')
  return match and #match
end

local function find_governing_title(start_line)
  local line = start_line
  while line > 0 do
    local level = get_title_level(line)
    if level then
      return line, level
    end
    line = line - 1
  end
  return nil
end

local function find_next_title(start_line, current_level)
  local line = start_line + 1
  local last_line = vim.fn.line('$')
  while line <= last_line do
    local next_level = get_title_level(line)
    if next_level and next_level <= current_level then
      return line
    end
    line = line + 1
  end
  return nil
end

M.select_under_title = function(include_title)
  local title_line, title_level = find_governing_title(vim.fn.line('.'))

  if not title_line then
    return
  end

  local select_top = include_title and title_line or title_line + 1

  local next_title_line = find_next_title(title_line, title_level)
  local select_bottom

  if next_title_line then
    select_bottom = next_title_line - 1
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

return M
