return function(data, w, opts)
  local total_str_w = -1 -- cuz last tab doesnt need gap

  for _, v in ipairs(data) do
    if v ~= "_pad_" then
      -- 2 = border, 2 = left/right txt padding, 1 = gap
      total_str_w = total_str_w + vim.api.nvim_strwidth(v) + 5
    end
  end

  local lines = { {}, {}, {} }

  local datalen = #data
  for i, v in ipairs(data) do
    if v == "_pad_" then
      local emptychar = string.rep(" ", w - total_str_w)
      table.insert(lines[1], { emptychar })
      table.insert(lines[2], { emptychar })
      table.insert(lines[3], { emptychar })
    else
      local hchar = string.rep("─", vim.api.nvim_strwidth(v) + 2)
      local hl = (opts.active == v and (opts.hlon or "normal")) or (opts.hloff or "commentfg")
      table.insert(lines[1], { "┌" .. hchar .. "┐", hl })
      table.insert(lines[2], { "│ " .. v .. " │", hl })
      table.insert(lines[3], { "└" .. hchar .. "┘", hl })

      if i ~= datalen then
        table.insert(lines[1], { " " })
        table.insert(lines[2], { " " })
        table.insert(lines[3], { " " })
      end
    end
  end

  return lines
end
