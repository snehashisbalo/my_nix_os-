-- Catppuccin Mocha, matching ~/omarchy-catppuccin-dark's `neovim.lua`.
--
-- NOTE: this file is currently never loaded. `lua/config/lazy.lua` carries an
-- identical, working copy of this spec, because lazy's `import = "plugins"`
-- only descends into a subdirectory that has an `init.lua` and only
-- `lua/plugins/lsp/` has one. Delete this file once the import is fixed.
--
-- Merges into LazyVim's own catppuccin spec (pulled in by
-- `import = "lazyvim.plugins"`) rather than replacing it: LazyVim supplies
-- `lsp_styles` and a long `integrations` list worth keeping, and `opts` is a
-- function here so the merge is deep. A plain table would replace
-- `integrations` wholesale and silently drop LazyVim's plugins.
return {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  name = "catppuccin",
  -- Catppuccin reads `@lsp` groups that a previously loaded colorscheme may
  -- have left behind; clearing them first keeps `native_lsp` authoritative.
  init = function()
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
      vim.api.nvim_set_hl(0, group, {})
    end
  end,
  opts = function(_, opts)
    opts.flavour = "mocha"
    opts.transparent_background = true
    opts.term_colors = true
    opts.float = vim.tbl_deep_extend("force", opts.float or {}, { transparent = true })
    -- `styles` entries are lists of style names, not `{ italic = true }` maps:
    -- the compiler does `for _, style in pairs(...)`, so a map makes it emit
    -- `true = true` and the whole colorscheme fails to load.
    opts.styles = vim.tbl_deep_extend("force", opts.styles or {}, {
      comments = { "italic" },
      conditionals = { "italic" },
    })
    opts.integrations = vim.tbl_deep_extend("force", opts.integrations or {}, {
      native_lsp = { enabled = true },
      which_key = true,
    })
    return opts
  end,
  -- `config` rather than letting lazy call `setup(opts)`, because
  -- `LazyVim.opts.colorscheme` has already run `:colorscheme catppuccin` by
  -- now: that compiles the highlights from catppuccin's *defaults*, and
  -- `setup` only records options without recompiling. Reloading here is what
  -- actually applies the transparency and styles above.
  config = function(_, opts)
    require("catppuccin").setup(opts)
    if vim.g.colors_name == "catppuccin" then
      vim.cmd.colorscheme "catppuccin"
    end
  end,
}
