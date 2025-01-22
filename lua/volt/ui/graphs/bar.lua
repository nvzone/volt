local utils = require "volt.ui.graphs.utils"

local gen_graph = function(lines, val, opts)
  local barchar = string.rep(opts.icon or "█", opts.w)
  local emptychar = string.rep(" ", opts.w)
  local gap = string.rep(" ", opts.gap)
  local dual_hl = opts.dual_hl
  local format_hl = opts.format_hl

  val = vim.tbl_map(function(x)
    return (math.floor(x / 10) * 10) / 10
  end, val)

  for _, v in ipairs(val) do
    for i = 10, 1, -1 do
      local cell = v >= i and barchar or emptychar
      local kekw = (11 - i) <= 0 and 11 or (11 - i)
      local hl = opts.hl or "exgreen"

      if dual_hl then
        hl = v <= i and dual_hl[1] or dual_hl[2]
      elseif format_hl then
        hl = opts.format_hl(v * 10)
      end

      table.insert(lines[kekw], { cell, hl })
      table.insert(lines[kekw], { gap })
    end
  end
end

return function(data)
  local lines = {}

  local total_w = #data.val * (data.baropts.w + data.baropts.gap) + 1
  local bottom_line = { "└" .. string.rep("─", total_w), "linenr" }

  local sidelabels_data = utils.gen_labels(data.format_labels)
  local sidelabels = sidelabels_data.labels

  local l_pad = { string.rep(" ", sidelabels_data.maxw) }

  for i = 10, 1, -1 do
    local line = {}
    table.insert(line, { sidelabels[i], "commentfg" })
    table.insert(line, { " │ ", "linenr" })
    table.insert(lines, line)
  end

  gen_graph(lines, data.val, data.baropts)

  table.insert(lines, { l_pad, bottom_line })

  if data.footer_label then
    local footer = utils.footer_label(data.footer_label, total_w, sidelabels_data.maxw)
    table.insert(lines, footer)
  end

  return lines
end
