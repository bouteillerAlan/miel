local M = {}

function M.setup()
  require("oasis").setup({ style = "moonlight" })
  vim.cmd.colorscheme("oasis")

  local palette = require("miel.palette")
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = palette.gold })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = palette.gold })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.gold })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = palette.error })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = palette.warning })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = palette.hot_gold })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = palette.dim_gold })
  vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = palette.success })
  vim.api.nvim_set_hl(0, "GitSignsChange", { fg = palette.warning })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = palette.error })
end

return M
