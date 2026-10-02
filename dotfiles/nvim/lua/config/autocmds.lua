-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- Ensure statusline always shows in codecompanion buffers
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("codecompanion_status"),
  pattern = "codecompanion",
  callback = function()
    vim.opt.laststatus = 3
    vim.wo.statusline = ""
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = augroup("codecompanion_status_enter"),
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "codecompanion" then
      vim.opt.laststatus = 3
      vim.wo.statusline = ""
    end
  end,
})

-- Load custom configuration after LazyVim is ready
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    pcall(require, "config.custom")
  end,
})
