-- Christmas mode: nvim --cmd 'let g:alpha_xmas = 1'
-- Halloween mode: nvim --cmd 'let g:alpha_halloween = 1'
-- St. Patrick's mode: nvim --cmd 'let g:alpha_st_patricks = 1'
-- Easter mode: nvim --cmd 'let g:alpha_easter = 1'
-- Seasonal defaults: St. Patrick's in March, Easter in April, Halloween in October, Christmas in December and January.
local M = {}

function M.setup()
  local alpha = require("alpha")
        local theta = require("alpha.themes.theta")
        local dashboard = require("alpha.themes.dashboard")

        local palettes = {
          retro = { "#d70000", "#ff5f00", "#ffaf00", "#875f00" },
          xmas = { "#d70000", "#008700", "#ffd700", "#ffffff" },
          st_patricks = { "#169b62", "#ff883e", "#ffffff", "#ffd700" },
          easter = { "#ffafcc", "#bdb2ff", "#a2d2ff", "#caffbf" },
          halloween = { "#ff7518", "#7b2cbf", "#39a845", "#ffbf00" },
        }
        local greetings = {
          xmas = "Happy Xmas",
          st_patricks = "Happy St. Patrick's Day",
          easter = "Happy Easter",
          halloween = "Happy Halloween",
        }
        local seasonal_decorations = {
          xmas = { "🎅", "🎁" },
          st_patricks = { "🍀" },
          easter = { "🥚" },
          halloween = { "🦇", "🧛" },
        }
        local palette_order = { "retro", "xmas", "st_patricks", "easter", "halloween" }
        local month = tonumber(os.date("%m"))
        local seasonal_palette = month == 3 and "st_patricks"
          or month == 4 and "easter"
          or month == 10 and "halloween"
          or (month == 12 or month == 1) and "xmas"
          or "retro"
        local active_palette = vim.g.alpha_xmas == 1 and "xmas"
          or vim.g.alpha_st_patricks == 1 and "st_patricks"
          or vim.g.alpha_easter == 1 and "easter"
          or vim.g.alpha_halloween == 1 and "halloween"
          or seasonal_palette
        local retro_colors = palettes[active_palette]
        local function greeting()
          return greetings[active_palette] or os.date("%Y-%m-%d %H:%M")
        end
        table.insert(theta.header.val, "")
        table.insert(theta.header.val, greeting())
        local greeting_index = #theta.header.val

        local function apply_palette()
          for i, hex in ipairs(retro_colors) do
            vim.api.nvim_set_hl(0, "AlphaHeaderRetro" .. i, { fg = hex })
            vim.api.nvim_set_hl(0, "AlphaSnowRetro" .. i, { fg = hex })
          end
        end
        apply_palette()

        local n_colors = #retro_colors
        local n_lines = #theta.header.val
        local offset = 0
        local snow_namespace = vim.api.nvim_create_namespace("alpha_retro_snow")
        local snowflakes = {}
        local settled_flakes = {}
        local clearing_rows = {}
        local cleared_lines = 0
        local generated_flakes = 0
        local snow_frame = 0

        local function set_flake_character(flake)
          local decorations = seasonal_decorations[active_palette]
          flake.character = "#"
          -- Keep decorations sparse among the regular flakes.
          if decorations and math.random(1, 12) == 1 then
            flake.character = decorations[math.random(#decorations)]
          end
        end

        local function reset_flake(flake, width, height)
          flake.column = math.random(0, width - 1)
          flake.row = -math.random(0, height)
          flake.color = math.random(n_colors)
          set_flake_character(flake)
        end

        local function make_snowflakes(width, height)
          snowflakes = {}
          settled_flakes = {}
          clearing_rows = {}
          local count = math.max(18, math.min(48, math.floor(width * height / 120)))
          generated_flakes = generated_flakes + count
          for i = 1, count do
            local flake = { character = "#", speed = math.random(1, 3) }
            reset_flake(flake, width, height)
            snowflakes[i] = flake
          end
        end

        -- Keep flakes out of dashboard text while allowing them in its margins.
        local function is_empty_at(line, column)
          local display_column = 0
          for character_index = 0, vim.fn.strchars(line) - 1 do
            local character = vim.fn.strcharpart(line, character_index, 1)
            local character_width = vim.fn.strdisplaywidth(character)
            if column < display_column + character_width then return character == " " end
            display_column = display_column + character_width
          end
          return true
        end

        local function draw_flake(buffer, lines, flake)
          local line = lines[flake.row + 1]
          if line and is_empty_at(line, flake.column) then
            vim.api.nvim_buf_set_extmark(buffer, snow_namespace, flake.row, 0, {
              virt_text = { { flake.character, "AlphaSnowRetro" .. flake.color } },
              virt_text_pos = "overlay",
              virt_text_win_col = flake.column,
            })
          end
        end

        local function render_snow(buffer, width, height)
          vim.api.nvim_buf_clear_namespace(buffer, snow_namespace, 0, -1)
          local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
          for row_number, row in pairs(settled_flakes) do
            if not clearing_rows[row_number] or clearing_rows[row_number].visible then
              for _, flake in pairs(row) do
                draw_flake(buffer, lines, flake)
              end
            end
          end
          for _, flake in ipairs(snowflakes) do
            draw_flake(buffer, lines, flake)
          end

          local counter = string.format("l:%d f:%d", cleared_lines, generated_flakes)
          vim.api.nvim_buf_set_extmark(buffer, snow_namespace, 0, 0, {
            virt_text = { { counter, "AlphaSnowRetro3" } },
            virt_text_pos = "overlay",
            virt_text_win_col = math.max(0, width - vim.fn.strdisplaywidth(counter)),
          })
        end

        local function mark_full_rows(width, height)
          for row = 0, height - 1 do
            local flakes = settled_flakes[row]
            if flakes and vim.tbl_count(flakes) == width and not clearing_rows[row] then
              clearing_rows[row] = { frames = 8, visible = true }
            end
          end
        end

        local function delete_row(row)
          for destination = row, 1, -1 do
            settled_flakes[destination] = settled_flakes[destination - 1]
            for _, flake in pairs(settled_flakes[destination] or {}) do
              flake.row = destination
            end
          end
          settled_flakes[0] = nil

          local shifted_rows = {}
          for row_number, state in pairs(clearing_rows) do
            if row_number < row then
              shifted_rows[row_number + 1] = state
            elseif row_number > row then
              shifted_rows[row_number] = state
            end
          end
          clearing_rows = shifted_rows
          cleared_lines = cleared_lines + 1
        end

        local function process_clearing_rows()
          local row_to_delete = nil
          for row, state in pairs(clearing_rows) do
            state.frames = state.frames - 1
            state.visible = state.frames % 2 == 0
            if state.frames <= 0 and (not row_to_delete or row > row_to_delete) then
              row_to_delete = row
            end
          end
          if row_to_delete then delete_row(row_to_delete) end
        end

        -- color each header line, cycling through the palette
        local function apply_header_colors()
          theta.header.opts.hl = {}
          for i = 1, n_lines do
            local group = "AlphaHeaderRetro" .. (((i - 1 + offset) % n_colors) + 1)
            theta.header.opts.hl[i] = { { group, 0, -1 } }
          end
        end
        apply_header_colors()

        -- animate: flow the palette down the header, looping
        local uv = vim.uv or vim.loop
        local timer = nil
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "alpha",
          callback = function(args)
            if timer then return end
            local width = vim.api.nvim_win_get_width(0)
            local height = vim.api.nvim_win_get_height(0)
            make_snowflakes(width, height)
            timer = uv.new_timer()
            timer:start(0, 150, vim.schedule_wrap(function()
              if not vim.api.nvim_buf_is_valid(args.buf) then
                if timer then timer:stop(); timer:close(); timer = nil end
                return
              end
              if vim.api.nvim_get_current_buf() ~= args.buf then return end

              local current_width = vim.api.nvim_win_get_width(0)
              local current_height = vim.api.nvim_win_get_height(0)
              if current_width ~= width or current_height ~= height then
                width = current_width
                height = current_height
                make_snowflakes(width, height)
              end

              offset = (offset - 1) % n_colors
              snow_frame = snow_frame + 1
              for _, flake in ipairs(snowflakes) do
                if snow_frame % flake.speed == 0 then
                  local next_row = flake.row + 1
                  local below = settled_flakes[next_row]
                  if next_row >= height or (below and below[flake.column]) then
                    if flake.row >= 0 then
                      settled_flakes[flake.row] = settled_flakes[flake.row] or {}
                      settled_flakes[flake.row][flake.column] = {
                        character = flake.character,
                        color = flake.color,
                        column = flake.column,
                        row = flake.row,
                      }
                    end
                    reset_flake(flake, width, height)
                    generated_flakes = generated_flakes + 1
                  else
                    flake.row = next_row
                  end
                end
              end
              mark_full_rows(width, height)
              process_clearing_rows()
              theta.header.val[greeting_index] = greeting()
              apply_header_colors()
              alpha.redraw()
              render_snow(args.buf, width, height)
            end))
            vim.api.nvim_create_autocmd("BufUnload", {
              buffer = args.buf,
              once = true,
              callback = function()
                if timer then
                  timer:stop()
                  timer:close()
                  timer = nil
                end
              end,
            })
          end,
        })

        local function cycle_palette()
          local current_index = vim.fn.index(palette_order, active_palette)
          active_palette = palette_order[(current_index + 1) % #palette_order + 1]
          retro_colors = palettes[active_palette]
          theta.header.val[greeting_index] = greeting()
          for _, flake in ipairs(snowflakes) do
            set_flake_character(flake)
          end
          for _, row in pairs(settled_flakes) do
            for _, flake in pairs(row) do
              set_flake_character(flake)
            end
          end
          apply_palette()
          vim.notify("Alpha palette: " .. active_palette)
          alpha.redraw()
        end
        vim.api.nvim_create_user_command("AlphaCyclePalette", cycle_palette, {})

        -- Keep buffer lines available for flakes below the dashboard.
        table.insert(theta.config.layout, {
          type = "padding",
          val = function() return vim.api.nvim_win_get_height(0) end,
        })

        theta.buttons.val = {
          dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
          dashboard.button("SPC f f", "  Find file", ":Telescope find_files<CR>"),
          dashboard.button("SPC f r", "  Recent files", ":Telescope oldfiles<CR>"),
          dashboard.button("SPC f g", "󰱼  Live grep", ":Telescope live_grep<CR>"),
          dashboard.button("u", "󰚰  Update plugins", ":Lazy sync<CR>"),
          dashboard.button("x", "󰜬  Cycle seasonal colors", ":AlphaCyclePalette<CR>"),
          dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
        }

  alpha.setup(theta.config)
end

return M
