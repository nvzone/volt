local linew = require("volt.ui.components").line_w

--- @param lines string[][][]|string[][]
--- @param w integer
--- @param pad integer
local function add_empty_space(lines, w, pad)
  for _, line in ipairs(lines) do
    table.insert(line, { string.rep(" ", w - linew(line) + pad) })
  end

  return lines
end

--- @param t1 any[]
--- @param t2 any[]
local function append_tb(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
end

--- @param columns { lines: string[][][]|string[][], w: integer, pad?: integer }[]
return function(columns)
  local ui_sections = {} ---@type (string[][][]|string[][])[]
  local empty_space = {} ---@type string[][]
  local h = 0

  for _, column in ipairs(columns) do
    local pad = column.pad or 0
    table.insert(ui_sections, add_empty_space(column.lines, column.w, pad))
    table.insert(empty_space, { { string.rep(" ", column.w + pad) } })

    local col_h = #column.lines
    if h < col_h then
      h = col_h
    end
  end

  local result = {}

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
