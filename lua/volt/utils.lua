local buf_i = 1

--- @param hex integer|nil|?
--- @return string str
local function hexadecimal_to_hex(hex)
  return "#" .. ("%06x"):format(not hex and 0 or hex)
end

---@class volt.Utils
local M = {}

--- @param bufs integer[]
function M.cycle_bufs(bufs)
  buf_i = buf_i == #bufs and 1 or buf_i + 1
  vim.api.nvim_set_current_win(vim.fn.bufwinid(bufs[buf_i]))
end

--- @param buf integer
--- @param step number
function M.cycle_clickables(buf, step)
  local bufstate = require("volt.state")[buf]
  local lines = {} ---@type integer[]
  for row, val in pairs(bufstate.clickables) do
    if #val > 0 then
      table.insert(lines, row)
    end
  end

  local cur_row = vim.api.nvim_win_get_cursor(0)[1]
  local len = #lines
  local from_loop = step > 0 and 1 or len
  local to_loop = step > 0 and len or 1
  for i = from_loop, to_loop, step do
    if (step > 0 and lines[i] > cur_row) or (step < 0 and lines[i] < cur_row) then
      vim.api.nvim_win_set_cursor(0, { lines[i], 0 })
      return
    end
  end
end

function M.close(val)
  local event_bufs = require("volt.events").bufs
  for _, buf in ipairs(val.bufs) do
    local valid_buf = vim.api.nvim_buf_is_valid(buf)
    if valid_buf then
      vim.api.nvim_buf_delete(buf, { force = true })
      require("volt.state")[buf] = nil
    end

    --- remove buf from event_bufs table
    for i, bufid in ipairs(event_bufs) do
      if bufid == buf then
        table.remove(event_bufs, i)
      end
    end

    if val.close_func then
      val.close_func(buf)
    end
  end

  if val.after_close then
    val.after_close()
  end

  vim.g.nvmark_hovered = nil
end

--- @param name string
--- @return vim.api.keyset.highlight result
function M.get_hl(name)
  local result = {} ---@type vim.api.keyset.highlight
  local hl = vim.api.nvim_get_hl(0, { name = name })

  if hl.fg then
    result.fg = hexadecimal_to_hex(hl.fg)
  end
  if hl.bg then
    result.bg = hexadecimal_to_hex(hl.bg)
  end

  return result
end

return M
