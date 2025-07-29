---------------------------------------------------------
-- plugin's interface
---------------------------------------------------------

-- load main module file
local module = require("kontur.module")

---@class Config
---@field indent_object_char string which char used after select INDENT operator to form a text-object
---@field heading_object_char string which char used after select under HEADING operator to form a text-object
---@field prefix_object_char string which char used after select PREFIX operator to form a text-object
local config = {
  indent_object_char = 'i',
  heading_object_char = 'h',
  prefix_object_char = 'p',
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  for _,mode in ipairs({ 'x', 'o' }) do
    vim.api.nvim_set_keymap(mode, 'i' .. M.config.indent_object_char, ':<c-u>lua require("kontur").select_indent()<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'i' .. M.config.heading_object_char, ':<c-u>lua require("kontur").select_under_heading()<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'i' .. M.config.prefix_object_char, ':<c-u>lua require("kontur").select_prefix_block()<cr>', { noremap = true, silent = true })
  end
end

-- this function can be called by require("kontur")
M.select_indent = function()
  return module.select_indent()
end

M.select_under_heading = function()
  return module.select_under_heading()
end

M.select_prefix_block = function()
  return module.select_prefix_block()
end

return M
