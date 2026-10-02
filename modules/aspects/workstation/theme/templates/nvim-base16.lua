-- Rendered by Noctalia (user template "nvim-base16") into
-- <state>/nvim/noctalia/theme.lua. DO NOT EDIT: regenerated on every theme
-- change. Loaded by lua/plugins/noctalia-base16.lua.
--
-- Role mapping: Noctalia's Material 3 roles onto base16 slots, so
-- RRethy/base16-nvim and any plugin reading base16 groups light up.
--
-- Every role used below is also used by Noctalia's own built-in templates, so
-- the placeholders are guaranteed to resolve. Do not add roles that are not
-- listed there: an unresolved placeholder renders as an empty string, which
-- base16 rejects outright.
local M = {}

function M.apply()
  local ok_base16, base16 = pcall(require, "base16-colorscheme")
  if not ok_base16 then
    return false
  end

  -- base16.setup() writes the highlight groups directly; it returns nothing,
  -- so there is no colorscheme name to :colorscheme afterwards.
  base16.setup({
    base00 = "{{ colors.surface.default.hex }}",
    base01 = "{{ colors.surface_container.default.hex }}",
    base02 = "{{ colors.surface_container_high.default.hex }}",
    base03 = "{{ colors.outline_variant.default.hex }}",
    base04 = "{{ colors.outline.default.hex }}",
    base05 = "{{ colors.on_surface_variant.default.hex }}",
    base06 = "{{ colors.on_surface.default.hex }}",
    base07 = "{{ colors.on_background.default.hex }}",
    base08 = "{{ colors.error.default.hex }}",
    base09 = "{{ colors.tertiary.default.hex }}",
    base0A = "{{ colors.secondary.default.hex }}",
    base0B = "{{ colors.primary.default.hex }}",
    base0C = "{{ colors.surface_variant.default.hex }}",
    base0D = "{{ colors.primary_container.default.hex }}",
    base0E = "{{ colors.secondary_container.default.hex }}",
    base0F = "{{ colors.tertiary_container.default.hex }}",
  })

  -- Claim a colorscheme name. Plugins and this config's own autocmds branch on
  -- vim.g.colors_name, and leaving it unset makes them believe no theme is
  -- loaded (see lua/core/overrides.lua).
  vim.g.colors_name = "noctalia"

  vim.cmd "redrawstatus"
  return true
end

return M