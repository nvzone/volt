local default_opts = {
  icons = { on = " 󰄰", off = " ·" },
  hl = { on = "exblue", off = "commentfg" },
  sidelabels = true,
}

---@param lines string[][]
---@param val integer[]
local function gen_graph(lines, val, baropts)
  val = vim.tbl_map(function(x)
    return (math.floor(x / 10) * 10) / 10
  end, val)

  local arrlen = #val
  local icons = baropts.icons
  for row_i, v in ipairs(val) do
    for i = 10, 1, -1 do
      local icon = v == i and icons.on or icons.off
      if v == i and baropts.format_icon then
        icon = baropts.format_icon(v * 10)
      end

      local new_i = (11 - i) <= 0 and 11 or (11 - i)
      local hl = v == i and baropts.hl.on or baropts.hl.off
      if v == i and baropts.format_hl then
        hl = baropts.format_hl(v * 10)
      end

      table.insert(lines[new_i], { icon, hl })
      if row_i ~= arrlen then
        table.insert(lines[new_i], { " " })
      end
    end
  end
end

return function(data)
  data.baropts = vim.tbl_extend("force", default_opts, data.baropts or {})

  local lines = {}
  local total_w = #data.val * 3
  local bottom_line = { "└" .. ("─"):rep(total_w), "linenr" }

  local utils = require("volt.ui.graphs.utils")
  local sidelabels_data = utils.gen_labels(data.format_labels)
  local sidelabels = sidelabels_data.labels
  if data.baropts.sidelabels then
    for i = 10, 1, -1 do
      local line = {}
      table.insert(line, { sidelabels[i], "commentfg" })
      table.insert(line, { " │", "linenr" })
      table.insert(lines, line)
    end

    table.insert(lines, { { (" "):rep(sidelabels_data.maxw) }, bottom_line })
  else
    for _ = 1, 10, 1 do
      table.insert(lines, {})
    end
  end

  gen_graph(lines, data.val, data.baropts)

  if data.footer_label then
    local footer = utils.footer_label(data.footer_label, total_w, sidelabels_data.maxw)
    table.insert(lines, footer)
  end

  return lines
end
