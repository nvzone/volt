--- @param tb string[][][][]|string[][][]|string[][]
--- @param w string|integer
local function get_column_widths(tb, w)
  local fit_w = type(w) == "string"
  local maxrow = #tb[1]
  local sum = 0
  local result = {}
  for i = 1, maxrow do
    local maxlen = 0
    for _, row in ipairs(tb) do
      local tmpw = type(row[i]) == "table" and require("volt.ui.components").line_w(row[i])
        or vim.api.nvim_strwidth(tostring(type(row[i]) == "table" and row[i][1] or row[i]))

      maxlen = math.max(maxlen, tmpw)
    end

    table.insert(result, maxlen)
    sum = sum + maxlen
  end

  local ratio = math.floor((fit_w and sum or w - sum) / maxrow)
  local col_widths = vim.tbl_map(function(x)
    sum = sum + ratio
    return x + ratio - 2
  end, result)
  if not fit_w then
    -- -1 cuz last col has right border too
    col_widths[#col_widths] = col_widths[#col_widths] + (fit_w and sum or w - sum) - 1
  end

  return col_widths
end

local border_chars = {
  corners_left = { top = "┌", bot = "└", none = "├" },
  corners_right = { top = "┐", bot = "┘", none = "┤" },
  mid = { top = "┬", bot = "┴", none = "┼" },
}

--- @param points integer[]
--- @param row_type? string|"none"
local function table_border(points, row_type)
  row_type = row_type or "none"

  local tblen, str = #points, ""
  for i, n in ipairs(points) do
    local t_char = border_chars.mid[row_type]
    t_char = i == tblen and "" or t_char
    str = str .. ("─"):rep(n + 1) .. t_char
  end
  return { { border_chars.corners_left[row_type] .. str .. border_chars.corners_right[row_type], "linenr" } }
end

--- @generic T: table
--- @param tbl T
--- @param w string|integer
--- @param header_hl? string
--- @param title? string[]|string
--- @return T lines
return function(tbl, w, header_hl, title)
  local col_widths = get_column_widths(tbl, w)

  local lines = {} --- @type string[][][]|string[][]
  local tb_border_up = table_border(col_widths, "top")
  local tb_border_middle = table_border(col_widths)
  local tb_border_down = table_border(col_widths, "bot")

  table.insert(lines, tb_border_up)
  local end_i = #tbl

  for line_i, row in ipairs(tbl) do
    local line = {} --- @type string[][]

    for i, v in ipairs(row) do
      local strlen = type(v) == "table" and require("volt.ui.components").line_w(v)
        or vim.api.nvim_strwidth(tostring(v))
      local pad_w = math.floor((col_widths[i] - strlen) / 2)
      local l_pad = (" "):rep(pad_w)
      local r_pad = (" "):rep(col_widths[i] - pad_w - strlen)
      local hl = (line_i == 1 and (header_hl or "exgreen") or "normal")

      table.insert(line, { "│ ", "linenr" })

      -- Complex row i.e table of virt text..
      if type(v) == "table" then
        table.insert(line, { l_pad })
        for _, virt in ipairs(v) do
          table.insert(line, virt)
        end
        table.insert(line, { r_pad })
      else
        -- Simple row i.e just text
        table.insert(line, { l_pad .. v .. r_pad, hl })
      end

      table.insert(line, { (#row == i and "│") or "", "linenr" })
    end

    table.insert(lines, line)
    table.insert(lines, line_i == end_i and tb_border_down or tb_border_middle)
  end

  if title then
    table.insert(lines, 1, { title })
  end

  return lines
end
