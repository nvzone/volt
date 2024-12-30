local M = {}

--- @class CheckboxOptions
--- @field active boolean Indicates if the checkbox is active.
--- @field txt string The text to display next to the checkbox.
--- @field check string|nil Replace the default check icon with a custom one.
--- @field uncheck string|nil Replace the deafult unchecked icon with a custom one.
--- @field hlon? string|nil Highlight for the active state (optional).
--- @field hloff? string|nil Highlight for the inactive state (optional).
--- @field actions table|nil Actions associated with the checkbox (optional).

--- @param o CheckboxOptions The options for the checkbox.
--- @return string[] A table containing the checkbox representation.
M.checkbox = function(o)
  return {
    (o.active and (o.check or "") or (o.uncheck or "")).. "  " .. o.txt,
    o.active and (o.hlon or "String") or (o.hloff or "ExInactive"),
    o.actions,
  }
end

--- @class ProgressOptions
--- @field w number The total width of the progress bar.
--- @field val number The current value of the progress (0 to 100).
--- @field icon? table active/inactive icon styles, ex: { on = "", off = ""}
--- @field hl? table  active/inactive highlights, ex: { on = "", off = ""}

--- @param o ProgressOptions The options for the progress bar.
--- @return table[] A table containing two elements: the active and inactive parts of the progress bar.
M.progressbar = function(o)
  local opts = {
    icon = { on = "-", off = "-" },
    hl = { on = "exred", off = "linenr" },
  }

  o = vim.tbl_deep_extend("force", opts, o)

  local activelen = math.floor(o.w * (o.val / 100))
  local inactivelen = o.w - activelen

  return {
    { string.rep(o.icon.on, activelen), o.hl.on },
    { string.rep(o.icon.off, inactivelen), o.hl.off },
  }
end

M.separator = function(char, w, hl)
  return { { string.rep(char or "─", w), hl or "linenr" } }
end

M.grid_row = function(tb)
  local result = {}
  for _, lines in ipairs(tb) do
    for _, line in ipairs(lines) do
      table.insert(result, line)
    end
  end

  return result
end

M.line_w = function(line)
  local w = 0

  for _, cell in ipairs(line) do
    w = w + vim.api.nvim_strwidth(cell[1])
  end

  return w
end

M.border = function(lines, hl)
  hl = hl or "linenr"

  local maxw = 0
  local line_widths = {}

  for _, line in ipairs(lines) do
    local linew = M.line_w(line)

    if maxw < linew then
      maxw = linew
    end

    table.insert(line_widths, linew)
  end

  for i, _ in ipairs(lines) do
    table.insert(lines[i], 1, { "│ ", hl })
    local rpad = string.rep(" ", maxw - line_widths[i])
    table.insert(lines[i], { rpad .. " │", hl })
  end

  maxw = maxw + 2

  local horiz_chars = string.rep("─", maxw)

  table.insert(lines, 1, { { "┌" .. horiz_chars .. "┐", hl } })
  table.insert(lines, { { "└" .. horiz_chars .. "┘", hl } })
end

M.hpad = function(line, w)
  local pad_w = w - M.line_w(line) - 5

  for i, v in ipairs(line) do
    if v[1] == "_pad_" then
      line[i][1] = string.rep(" ", pad_w)
    end
  end

  return line
end

return M
