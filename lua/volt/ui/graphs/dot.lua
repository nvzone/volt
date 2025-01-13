local utils = require "volt.ui.graphs.utils"

local gen_graph = function(lines, val, hl)
  val = vim.tbl_map(function(x)
    return x / 10
  end, val)

  for _, v in ipairs(val) do
    for i = 10, 1, -1 do
      local cell = v == i and " 󰄰" or " ·"
      local new_i = (11 - i) <= 0 and 11 or (11 - i)
      table.insert(lines[new_i], { cell, v == i and hl[1] or hl[2] })
      table.insert(lines[new_i], { " " })
    end
  end
end

return function(data)
  local lines = {}
  local total_w = #data.val * 3
  local bottom_line = { "└" .. string.rep("─", total_w), "linenr" }

  local sidelabels_data = utils.gen_labels(data.format_labels)
  local sidelabels = sidelabels_data.labels

  for i = 10, 1, -1 do
    local line = {}
    table.insert(line, { sidelabels[i], "commentfg" })
    table.insert(line, { " │", "linenr" })
    table.insert(lines, line)
  end

  table.insert(lines, { { string.rep(" ", sidelabels_data.maxw) }, bottom_line })
  gen_graph(lines, data.val, data.hl or { "exblue", "commentfg" })

  local footer = utils.footer_label(data.footer_label, total_w, sidelabels_data.maxw)
  table.insert(lines, footer)


  return lines
end
