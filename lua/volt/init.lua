local M = {}
local api = vim.api
local map = vim.keymap.set
local draw = require "volt.draw"
local state = require "volt.state"
local utils = require "volt.utils"

local get_section = function(tb, name)
  for _, value in ipairs(tb) do
    if value.name == name then
      return value
    end
  end
end

M.gen_data = function(data)
  for _, info in ipairs(data) do
    state[info.buf] = {}

    local buf = info.buf
    local v = state[buf]

    v.clickables = {}
    v.hoverables = {}
    v.xpad = info.xpad
    v.layout = info.layout
    v.ns = info.ns
    v.buf = buf

    local row = 0

    for _, value in ipairs(v.layout) do
      local lines = value.lines(buf)
      value.row = row
      row = row + #lines
    end

    v.h = row
  end
end

M.redraw = function(buf, names)
  local v = state[buf]

  if names == "all" then
    for _, section in ipairs(v.layout) do
      draw(buf, section)
    end
    return
  end

  if type(names) == "string" then
    draw(buf, get_section(v.layout, names))
    return
  end

  for _, name in ipairs(names) do
    draw(buf, get_section(v.layout, name))
  end
end

M.set_empty_lines = function(buf, n, w)
  local empty_lines = {}

  for _ = 1, n, 1 do
    table.insert(empty_lines, string.rep(" ", w))
  end

  api.nvim_buf_set_lines(buf, 0, -1, true, empty_lines)
end

M.mappings = function(val)
  for _, buf in ipairs(val.bufs) do
    -- cycle bufs
    map("n", "<C-t>", function()
      utils.cycle_bufs(val.bufs)
    end, { buffer = buf })

    -- close
    map("n", "q", function()
      utils.close(val)
    end, { buffer = buf })

    map("n", "<ESC>", function()
      utils.close(val)
    end, { buffer = buf })

    if val.winclosed_event then
      vim.api.nvim_create_autocmd("WinClosed", {
        buffer = buf,
        callback = function()
          vim.schedule(function()
            if state[buf] then
              utils.close(val)
            end
          end)
        end,
      })
    end
  end
end

M.run = function(buf, opts)
  vim.bo[buf].filetype = "VoltWindow"

  if opts.custom_empty_lines then
    opts.custom_empty_lines()
  else
    M.set_empty_lines(buf, opts.h, opts.w)
  end

  require "volt.highlights"

  M.redraw(buf, "all")

  api.nvim_set_option_value("modifiable", false, { buf = buf })

  if not vim.g.extmarks_events then
    require("volt.events").enable()
  end
end

M.toggle_func = function(open_func, ui_state)
  if ui_state then
    open_func()
  else
    api.nvim_feedkeys("q", "x", false)
  end
end

M.close = function(buf)
  if not buf then
    api.nvim_feedkeys("q", "x", false)
    return
  end

  api.nvim_buf_call(buf, function()
    api.nvim_feedkeys("q", "x", false)
  end)
end

return M
