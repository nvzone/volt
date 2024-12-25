local get_column_widths = function(tb, w)
  local fit_w = type(w) == "string"
  local maxrow = #tb[1]
  local sum = 0
  local result = {}

  for i = 1, maxrow do
    local maxlen = 0

    for _, row in ipairs(tb) do
      local txt = type(row[i]) == "table" and row[i][1] or row[i]
      local str = tostring(txt)
      maxlen = math.max(maxlen, vim.api.nvim_strwidth(str))
    end

    table.insert(result, maxlen)
    sum = sum + maxlen
  end

  local remaining_space = fit_w and sum or w - sum
  local ratio = math.floor(remaining_space / maxrow)

  local col_widths = vim.tbl_map(function(x)
    sum = sum + ratio
    return x + ratio - 2
  end, result)

  if not fit_w then
    local last_item = col_widths[#col_widths]
    -- -1 cuz last col has right border too
    col_widths[#col_widths] = last_item + (fit_w and sum or w - sum) - 1
  end

  return col_widths
end

local border_chars = {
  mid = { top = "┬", bot = "┴", none = "┼" },
  corners_left = { top = "┌", bot = "└", none = "├" },
  corners_right = { top = "┐", bot = "┘", none = "┤" },
}

local table_border = function(points, row_type)
  local str = ""
  local tblen = #points

  for i, n in ipairs(points) do
    local t_char = border_chars.mid[row_type or "none"]
    t_char = i == tblen and "" or t_char

    str = str .. string.rep("─", n + 1) .. t_char
  end

  local l_char = border_chars.corners_left[row_type or "none"]
  local r_char = border_chars.corners_right[row_type or "none"]

  return { { l_char .. str .. r_char, "linenr" } }
end

return function(tbl, w, header_hl, title)
  local col_widths = get_column_widths(tbl, w)

  local lines = {}
  local tb_border_up = table_border(col_widths, "top")
  local tb_border_middle = table_border(col_widths)
  local tb_border_down = table_border(col_widths, "bot")

  table.insert(lines, tb_border_up)
  local end_i = #tbl

  for line_i, row in ipairs(tbl) do
    local line = {}

    for i, v in ipairs(row) do
      local maxlen = col_widths[i]
      local is_virt = type(v) == "table"
      local text = tostring(is_virt and v[1] or v)
      local strlen = vim.api.nvim_strwidth(text)

      local pad_w = math.floor((maxlen - strlen) / 2)

      local l_pad = string.rep(" ", pad_w)
      local r_pad = string.rep(" ", maxlen - pad_w - strlen)

      local hl = (line_i == 1 and (header_hl or "exgreen") or "normal")
      hl = is_virt and v[2] or hl

      local str = l_pad .. text .. r_pad

      table.insert(line, { "│ ", "linenr" })
      table.insert(line, { str, hl })
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
