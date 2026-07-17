--- @generic T: table
--- @param lines T
--- @param w integer
--- @param pad integer
--- @return T lines
local function add_empty_space(lines, w, pad)
  for _, line in ipairs(lines) do
    table.insert(line, { (" "):rep(w - require("volt.ui.components").line_w(line) + pad) })
  end
  return lines
end

---@generic T: table, V: table
--- @param t1 T
--- @param t2 V
local function append_tb(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
end

--- @param columns { lines: string[][][], w: integer, pad?: integer }[]
--- @return string[][][] result
return function(columns)
  local ui_sections = {} ---@type string[][][]|string[][]
  local empty_space = {} ---@type string[][]
  local h = 0

  for _, column in ipairs(columns) do
    local pad = column.pad or 0
    table.insert(ui_sections, add_empty_space(column.lines, column.w, pad))
    table.insert(empty_space, { { (" "):rep(column.w + pad) } })

    local col_h = #column.lines
    if h < col_h then
      h = col_h
    end
  end

  local result = {} ---@type string[][][]
  for i = 1, h do
    if not result[i] then
      table.insert(result, {})
    end
    for j = 1, #ui_sections do
      append_tb(result[i], (ui_sections[j][i] or empty_space[j]))
    end
  end

  return result
end
