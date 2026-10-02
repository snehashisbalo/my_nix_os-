local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      -- LazyVim applies its `opts.colorscheme` in the plugin's own config
      -- function, so this is what actually decides the active colorscheme.
      -- See ~/omarchy-catppuccin-dark/neovim.lua.
      opts = {
        colorscheme = "catppuccin",
      },
    },
    -- import/override with your plugins
    { import = "plugins" },

    -- Catppuccin Mocha, ported from ~/omarchy-catppuccin-dark/neovim.lua.
    --
    -- Duplicated from lua/plugins/colorschemes/catppuccin.lua on purpose. That
    -- file is currently never loaded: lazy's `import` only descends into a
    -- subdirectory that has an `init.lua`, so of lua/plugins/*/ only `lsp/`
    -- (the one group with an init.lua) is ever imported. The same spec also
    -- has to live here because `opts` is a function, and a spec that supplies
    -- `config` instead would make lazy skip `setup(opts)` entirely.
    --
    -- Delete this block once lua/plugins/ actually imports (see TODO.md).
    {
      "catppuccin/nvim",
      lazy = false,
      priority = 1000,
      name = "catppuccin",
      -- Catppuccin reads `@lsp` groups a previously loaded colorscheme may have
      -- left behind; clearing them keeps `native_lsp` authoritative.
      init = function()
        for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
          vim.api.nvim_set_hl(0, group, {})
        end
      end,
      -- Merged into LazyVim's own catppuccin spec rather than replacing it, so
      -- its `lsp_styles` and long `integrations` list survive. A plain table
      -- would replace `integrations` wholesale and drop LazyVim's plugins.
      opts = function(_, opts)
        opts.flavour = "mocha"
        opts.transparent_background = true
        opts.term_colors = true
        opts.float = vim.tbl_deep_extend("force", opts.float or {}, { transparent = true })
        -- `styles` entries are lists of style names, not `{ italic = true }`
        -- maps: the compiler does `for _, style in pairs(...)`, so a map makes
        -- it emit `true = true` and the whole colorscheme fails to load.
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
      -- `LazyVim.opts.colorscheme` has already run `:colorscheme catppuccin`
      -- by now: that compiles the highlights from catppuccin's *defaults*, and
      -- `setup` only records options without recompiling. Reloading here is
      -- what actually applies the transparency and styles above.
      config = function(_, opts)
        require("catppuccin").setup(opts)
        if vim.g.colors_name == "catppuccin" then
          vim.cmd.colorscheme "catppuccin"
        end
      end,
    },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
