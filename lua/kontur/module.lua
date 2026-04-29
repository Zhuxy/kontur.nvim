---------------------------------------------------------
-- main function implementation here
---------------------------------------------------------

---@class NvimIndent
local M = {}

local is_blank_line = function(line)
  local line_content = vim.fn.getline(line)
  return line_content == nil or line_content:match("^%s*$")
end

local function select_line_range(select_top, select_bottom)
  vim.api.nvim_win_set_cursor(0, { select_top, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { select_bottom, 0 })
end

M.select_indent = function()
  local current_line = vim.fn.line(".")
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
  if select_top < 1 then
    select_top = 1
  end

  -- Find the bottom line of the indented block
  local select_bottom = current_line
  local last_line = vim.fn.line("$")
  while
    select_bottom < last_line and (is_blank_line(select_bottom + 1) or vim.fn.indent(select_bottom + 1) >= start_indent)
  do
    select_bottom = select_bottom + 1
  end

  if is_blank_line(select_bottom) then
    select_bottom = select_bottom - 1
  end

  select_line_range(select_top, select_bottom)
end

local function get_heading_level(line)
  local line_str = vim.fn.getline(line)
  if not line_str then
    return nil
  end
  local match = string.match(line_str, "^(#+)%s+.*$")
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
  local last_line = vim.fn.line("$")

  while line <= last_line do
    local next_level = get_heading_level(line)
    if next_level and next_level <= current_level then
      return line
    end
    line = line + 1
  end
  return nil
end

local function get_heading_selection_range(include_heading_line)
  local heading_line, heading_level = find_governing_heading(vim.fn.line("."))

  if not heading_line then
    return nil
  end

  local select_top = include_heading_line and heading_line or (heading_line + 1)
  local next_heading_line = find_next_heading(heading_line, heading_level)
  local select_bottom

  if next_heading_line then
    select_bottom = next_heading_line - 1
  else
    select_bottom = vim.fn.line("$")
  end

  while select_bottom >= select_top and is_blank_line(select_bottom) do
    select_bottom = select_bottom - 1
  end

  if select_top > select_bottom then
    return nil
  end

  return select_top, select_bottom
end

M.select_under_heading = function()
  local select_top, select_bottom = get_heading_selection_range(false)
  if not select_top then
    return
  end

  select_line_range(select_top, select_bottom)
end

M.select_around_heading = function()
  local select_top, select_bottom = get_heading_selection_range(true)
  if not select_top then
    return
  end

  select_line_range(select_top, select_bottom)
end

local function get_prefix_pattern(line)
  local line_content = vim.fn.getline(line)
  if not line_content then
    return nil
  end

  -- Try to match a numbered list pattern (e.g., "1.", "12.")
  -- This pattern matches optional leading whitespace, then one or more digits, then a dot, then optional whitespace.
  local num_list_match = line_content:match("^%s*(%d+%.%s*)")
  if num_list_match then
    -- Return a pattern that matches any number followed by a dot and optional space at the beginning of the line
    return "^%s*%d+%.%s*"
  end

  -- Otherwise, get the first word as the literal prefix
  local literal_prefix = line_content:match("^%s*([^%s]+)")
  if not literal_prefix then
    return nil
  end

  -- Escape Lua pattern metacharacters without touching ordinary digits.
  local escaped_prefix = literal_prefix:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")

  -- Return a pattern that matches optional leading whitespace, then the escaped literal prefix
  return "^%s*" .. escaped_prefix
end

M.select_prefix_block = function()
  local current_line = vim.fn.line(".")
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
  local last_line = vim.fn.line("$")

  while select_bottom < last_line do
    local next_line_content = vim.fn.getline(select_bottom + 1)
    if next_line_content and next_line_content:match(pattern) then
      select_bottom = select_bottom + 1
    else
      break
    end
  end

  select_line_range(select_top, select_bottom)
end

local function is_pipe_table_line(line)
  local line_content = vim.fn.getline(line)
  return line_content ~= nil and not line_content:match("^%s*$") and line_content:find("|", 1, true) ~= nil
end

local function trim_pipe_cell(cell)
  return (cell:gsub("^%s*", ""):gsub("%s*$", ""))
end

local function get_pipe_cells(line_content)
  local content = line_content:gsub("^%s*", ""):gsub("%s*$", "")

  if content:sub(1, 1) == "|" then
    content = content:sub(2)
  end

  if content:sub(-1) == "|" then
    content = content:sub(1, -2)
  end

  local cells = {}
  for cell in (content .. "|"):gmatch("(.-)|") do
    table.insert(cells, trim_pipe_cell(cell))
  end

  return cells
end

local function is_markdown_table_delimiter(line)
  local line_content = vim.fn.getline(line)
  if not line_content or not line_content:find("|", 1, true) then
    return false
  end

  local cells = get_pipe_cells(line_content)
  if #cells == 0 then
    return false
  end

  for _, cell in ipairs(cells) do
    if not cell:match("^:?%-%-%-+:?$") then
      return false
    end
  end

  return true
end

local function find_table_delimiter(current_line)
  if is_markdown_table_delimiter(current_line) then
    return current_line
  end

  local line = current_line - 1
  while line >= 1 and is_pipe_table_line(line) do
    if is_markdown_table_delimiter(line) then
      return line
    end
    line = line - 1
  end

  line = current_line + 1
  local last_line = vim.fn.line("$")
  while line <= last_line and is_pipe_table_line(line) do
    if is_markdown_table_delimiter(line) then
      return line
    end
    line = line + 1
  end

  return nil
end

local function get_markdown_table_range(current_line)
  if not is_pipe_table_line(current_line) then
    return nil
  end

  local delimiter_line = find_table_delimiter(current_line)
  if not delimiter_line then
    return nil
  end

  local header_line = delimiter_line - 1
  if header_line < 1 or not is_pipe_table_line(header_line) then
    return nil
  end

  local select_bottom = delimiter_line
  local last_line = vim.fn.line("$")
  while select_bottom < last_line and is_pipe_table_line(select_bottom + 1) do
    select_bottom = select_bottom + 1
  end

  if current_line < header_line or current_line > select_bottom then
    return nil
  end

  return header_line, select_bottom
end

M.select_markdown_table = function()
  local select_top, select_bottom = get_markdown_table_range(vim.fn.line("."))
  if not select_top then
    return
  end

  select_line_range(select_top, select_bottom)
end

return M
