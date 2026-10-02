---@diagnostic disable: lowercase-global

local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    local err_msg = string.format("Failed to load %s:\n%s", module, result)
    vim.schedule(function()
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "Config Error" })
    end)
    return nil
  end
  return result
end

Colors = safe_require "config.colors" or {}
Icons = safe_require "config.icons" or {}
UI = safe_require "config.ui" or {}

safe_require "core.globals"
safe_require "core.commands"
safe_require "core.filetypes"
safe_require "core.overrides"

local colorscheme = require "core.colorscheme"
local highlights = require "core.highlights"
highlights.setup()
colorscheme.apply()

if vim.g.neovide then
  safe_require "core.neovide"
end
