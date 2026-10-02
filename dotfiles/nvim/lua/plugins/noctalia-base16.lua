-- Noctalia drives nvim's colours.
--
-- The palette is rendered by Noctalia's "nvim-base16" user template into
-- <state>/nvim/noctalia/theme.lua, a path home-manager does NOT manage. This
-- file only loads it, so the dotfile repo stays free of generated output.
--
-- Load order is load-bearing here:
--   * init.lua applies the saved colorscheme (theme.json) *after* lazy.nvim has
--     configured every plugin, so applying at plugin-load time would have its
--     highlights wiped by init.lua seconds later. Hooking ColorScheme catches
--     exactly that call, and a scheduled pass covers the case where the saved
--     colorscheme never changes.
--   * theme.json can have transparency enabled, and base16's Normal bg would
--     undo it, so transparency is re-applied after each colours pass.
--
-- Deliberately not on VeryLazy: that fires from UIEnter, which never happens in
-- headless nvim (`:h UIEnter`).
return {
  "RRethy/base16-nvim",
  config = function()
    local theme_path = vim.fn.stdpath("state") .. "/noctalia/theme.lua"

    local function apply()
      -- The placeholder written on a fresh machine is empty, and before the
      -- first theme-set the file may not exist at all. Either way, stay quiet.
      local ok, mod = pcall(dofile, theme_path)
      if not (ok and type(mod) == "table" and type(mod.apply) == "function") then
        return
      end
      pcall(mod.apply)

      pcall(function()
        require("core.colorscheme").reapply_transparency_if_enabled()
      end)
    end

    -- Nothing may silently win over Noctalia. Registered during plugin config,
    -- so this runs after init.lua's own autocmds and stays the last writer.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("NoctaliaTheme", { clear = true }),
      callback = apply,
    })

    vim.schedule(apply)

    -- Stop any previous handle before starting another one, otherwise each
    -- re-source of this file leaves a live handler behind.
    if _G.__noctalia_theme_signal then
      pcall(function()
        _G.__noctalia_theme_signal:stop()
        _G.__noctalia_theme_signal:close()
      end)
      _G.__noctalia_theme_signal = nil
    end

    local ok, signal = pcall(vim.uv.new_signal)
    if ok and signal then
      _G.__noctalia_theme_signal = signal
      -- Registering the handler is also what stops SIGUSR1 from killing nvim.
      signal:start("sigusr1", vim.schedule_wrap(apply))
    end
  end,
}