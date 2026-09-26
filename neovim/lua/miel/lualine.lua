local M = {}

function M.setup()
        -- Miel gold-on-navy palette.
        -- Only the mode segment (a) is a colored pill; everything else (b/c,
        -- mirrored as x/y) shares one flat background so it doesn't turn
        -- into a patchwork of differently-colored blocks. Because lualine
        -- only draws a section separator where the color actually changes,
        -- this still leaves a visible "/" and "\" right around the pill,
        -- with the location segment (z) mirroring the mode pill at the far
        -- right -- one flat run of text bookended by two colored badges.
        local palette = require("miel.palette")
        local bg_mantle = palette.mantle
        local text = palette.text
        local dim = palette.dim_gold
        local gold = palette.gold
        local gold_hot = palette.hot_gold
        local cream = palette.cream
        local good = palette.success
        local warn = palette.warning
        local critical = palette.error

        local miel_theme = {
          normal = {
            a = { bg = gold, fg = bg_mantle, gui = "bold" },
            b = { bg = bg_mantle, fg = text },
            c = { bg = bg_mantle, fg = dim },
          },
          insert = { a = { bg = good, fg = bg_mantle, gui = "bold" } },
          visual = { a = { bg = warn, fg = bg_mantle, gui = "bold" } },
          replace = { a = { bg = critical, fg = bg_mantle, gui = "bold" } },
          command = { a = { bg = cream, fg = bg_mantle, gui = "bold" } },
          terminal = { a = { bg = gold_hot, fg = bg_mantle, gui = "bold" } },
          inactive = {
            a = { bg = bg_mantle, fg = dim },
            b = { bg = bg_mantle, fg = dim },
            c = { bg = bg_mantle, fg = dim },
          },
        }

        -- Braille density bar in place of the plain "progress" percentage.
        -- "%%" is not a typo: a
        -- literal "%" in the statusline option must be doubled, or Vim's
        -- statusline parser errors out and the whole bar goes blank.
        local function scroll_pct()
          local line = vim.fn.line(".")
          local total = vim.fn.line("$")
          return total > 1 and math.floor((line - 1) / (total - 1) * 100) or 100
        end

        -- Each of the 6 blocks has a fixed color by position (not by scroll
        -- amount) so the gradient stays put and blocks simply light up in
        -- their own shade as you reach them, rather than the whole bar
        -- re-tinting. A lualine `color` option only tints a whole component
        -- one color, so instead this embeds "%#Group#" tokens straight into
        -- the returned string -- lualine's supported way to multi-color a
        -- single component -- using highlight groups defined once below.
        vim.api.nvim_set_hl(0, "MielBrailleHi", { fg = gold, bg = bg_mantle })
        vim.api.nvim_set_hl(0, "MielBrailleMid", { fg = gold_hot, bg = bg_mantle })
        vim.api.nvim_set_hl(0, "MielBrailleLo", { fg = palette.bronze, bg = bg_mantle })
        vim.api.nvim_set_hl(0, "MielBrailleEmpty", { fg = dim, bg = bg_mantle })

        local braille_tiers = {
          "MielBrailleHi", "MielBrailleHi",
          "MielBrailleMid", "MielBrailleMid",
          "MielBrailleLo", "MielBrailleLo",
        }

        local function braille_progress()
          local pct = scroll_pct()
          local width = #braille_tiers
          local filled = math.floor(pct / 100 * width)
          local parts = {}
          for i = 1, width do
            if i <= filled then
              parts[i] = "%#" .. braille_tiers[i] .. "#⣿"
            else
              parts[i] = "%#MielBrailleEmpty#⠁"
            end
          end
          -- the number matches the most recently lit block's shade
          local label_group = filled == 0 and "MielBrailleEmpty" or braille_tiers[math.min(filled, width)]
          return table.concat(parts) .. "%#" .. label_group .. "# " .. pct .. "%%"
        end

        -- telescope-style path shortening
        local function shorten_path(path, keep)
          keep = keep or 3
          local prefix = ""
          if path:sub(1, 1) == "/" then
            prefix = "/"
            path = path:sub(2)
          end
          local parts = vim.split(path, "/", { plain = true })
          local n = #parts
          if n > keep then
            for i = 1, n - keep do
              if parts[i] ~= "" and parts[i] ~= "~" and parts[i] ~= ".." then
                parts[i] = parts[i]:sub(1, 1)
              end
            end
          end
          return prefix .. table.concat(parts, "/")
        end

        local function shortened_filepath()
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname == "" then
            return "[No Name]"
          end
          -- ":p" -> always the full absolute path, like `pwd`
          local path = vim.fn.fnamemodify(bufname, ":p")
          local result = shorten_path(path, 3)
          if vim.bo.modified then
            result = result .. " [+]"
          end
          if vim.bo.readonly then
            result = result .. " [RO]"
          end
          return result
        end

        -- lsp client name instead of the filetype
        -- if multiple lsp is found we take the one that support "go-to-definition"
        -- if none we use the filetype
        local function lsp_short()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          local name
          for _, client in ipairs(clients) do
            if client.server_capabilities and client.server_capabilities.definitionProvider then
              name = client.name
              break
            end
          end
          name = name or (clients[1] and clients[1].name) or vim.bo.filetype
          return name:sub(1, 6)
        end

        local fraktur = {
          A = "𝕬", B = "𝕭", C = "𝕮", D = "𝕯", E = "𝕰", F = "𝕱", G = "𝕲",
          H = "𝕳", I = "𝕴", J = "𝕵", K = "𝕶", L = "𝕷", M = "𝕸", N = "𝕹",
          O = "𝕺", P = "𝕻", Q = "𝕼", R = "𝕽", S = "𝕾", T = "𝕿", U = "𝖀",
          V = "𝖁", W = "𝖂", X = "𝖃", Y = "𝖄", Z = "𝖅",
        }
        local fraktur_lower = {
          a = "𝖆", b = "𝖇", c = "𝖈", d = "𝖉", e = "𝖊", f = "𝖋", g = "𝖌",
          h = "𝖍", i = "𝖎", j = "𝖏", k = "𝖐", l = "𝖑", m = "𝖒", n = "𝖓",
          o = "𝖔", p = "𝖕", q = "𝖖", r = "𝖗", s = "𝖘", t = "𝖙", u = "𝖚",
          v = "𝖛", w = "𝖜", x = "𝖝", y = "𝖞", z = "𝖟",
        }

        -- LSP/treesitter loading progress is shown by fidget.nvim (see its
        -- plugin spec below) as floating notifications, not in here.
        require("lualine").setup({
          options = {
            theme = miel_theme,
            icons_enabled = false,
            component_separators = { left = "|", right = "|" },
            section_separators = { left = "", right = "" },
          },
          sections = {
            lualine_a = {
              {
                "mode",
                fmt = function(str)
                  -- V-LINE / V-BLOCK would otherwise all collapse to VISUAL's 𝖛
                  local overrides = { ["V-LINE"] = "l", ["V-BLOCK"] = "b" }
                  local first = overrides[str] or str:sub(1, 1):lower()
                  return fraktur_lower[first] or first
                end,
              },
            },
            lualine_b = {
              -- branch name in cream; diff (+/~/-) and diagnostics keep
              -- their own semantic colors (green/orange/red), which would
              -- lose meaning if flattened to one color too.
              { "branch", color = { fg = cream } },
              "diff",
              { "diagnostics", sections = { "error", "warn", "hint" } },
            },
            lualine_c = {
              shortened_filepath,
              function()
                return require("compress_size").status()
              end,
            },
            lualine_x = {
              "encoding",
              {
                -- line ending name + its raw bytes instead of unix/dos/mac
                "fileformat",
                fmt = function(str)
                  local eol = { unix = "lf 0A", dos = "crlf 0D0A", mac = "cr 0D" }
                  return eol[str] or str
                end,
              },
              lsp_short,
              "dap_breakpoints",
            },
            lualine_y = { braille_progress },
          },
        })
end

return M
