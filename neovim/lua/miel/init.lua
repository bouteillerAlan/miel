local M = {}

function M.setup(options)
  options = vim.tbl_deep_extend("force", {
    nvim = true,
    lualine = true,
  }, options or {})

  if options.nvim then
    require("miel.nvim").setup()
  end
  if options.lualine then
    require("miel.lualine").setup()
  end
end

return M
