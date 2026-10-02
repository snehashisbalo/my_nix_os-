-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize splits with arrow keys
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Center cursor on half page vertical jumps
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Center cursor when moving between search results
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "nzzzv", opts)

-- Clear highlights
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", opts)

-- INSERT --
keymap("i", "kj", "<Esc>", opts)

-- VISUAL --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "J", ":m >+1<CR>==", opts)
keymap("v", "K", ":m <-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", opts)

keymap("n", "Q", "<nop>")
keymap("n", "<leader>zx", "<cmd>!chmod +x %<cr>", { desc = "chmod +x", silent = true })
