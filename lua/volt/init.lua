--- @class VoltData.Layout
--- @field col_start? integer
--- @field lines fun(buf?: integer): (string[][][]|string[][])
--- @field name string
--- @field row? integer

--- @class VoltData
--- @field buf integer
--- @field layout VoltData.Layout[]
--- @field ns integer
--- @field xpad integer

---@class Volt
local M = {}
local draw = require("volt.draw")
local state = require("volt.state")
local utils = require("volt.utils")

--- @param tb VoltData.Layout[]
--- @param name string
--- @return VoltData.Layout|nil|?
local function get_section(tb, name)
  for _, value in ipairs(tb) do
    if value.name == name then
      return value
    end
  end
end

--- @param data VoltData[]
function M.gen_data(data)
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

--- @param buf integer
--- @param names string[]|string|"all"
function M.redraw(buf, names)
  local v = state[buf]
  if names == "all" then
    for _, section in ipairs(v.layout) do
      draw(buf, section)
    end
  elseif type(names) == "string" then
    draw(buf, get_section(v.layout, names))
  else
    for _, name in ipairs(names) do
      draw(buf, get_section(v.layout, name))
    end
  end
end

--- @param buf integer
--- @param n integer
--- @param w integer
function M.set_empty_lines(buf, n, w)
  local empty_lines = {} ---@type string[]
  for _ = 1, n, 1 do
    table.insert(empty_lines, (" "):rep(w))
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, empty_lines)
end

function M.mappings(val)
  for _, buf in ipairs(val.bufs) do
    -- cycle bufs
    vim.keymap.set("n", "<C-t>", function()
      utils.cycle_bufs(val.bufs)
    end, { buffer = buf })

    -- close
    vim.keymap.set("n", "q", function()
      utils.close(val)
    end, { buffer = buf })

    vim.keymap.set("n", "<ESC>", function()
      utils.close(val)
    end, { buffer = buf })

    if not val.winclosed_event then
      return
    end
    vim.api.nvim_create_autocmd("WinClosed", {
      buffer = buf,
      callback = function()
        if state[buf] then
          vim.schedule(function()
            utils.close(val)
          end)
        end
      end,
    })
  end
end

--- @param buf integer
function M.run(buf, opts)
  vim.api.nvim_set_option_value("filetype", "VoltWindow", { buf = buf })
  if opts.custom_empty_lines then
    opts.custom_empty_lines()
  else
    M.set_empty_lines(buf, opts.h, opts.w)
  end

  require("volt.highlights")

  M.redraw(buf, "all")

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  if not vim.g.extmarks_events then
    require("volt.events").enable()
  end
end

---@param open_func function
function M.toggle_func(open_func, ui_state)
  if ui_state and open_func then
    open_func()
  else
    vim.api.nvim_feedkeys("q", "x", false)
  end
end

---@param buf? integer
function M.close(buf)
  if not buf then
    vim.api.nvim_feedkeys("q", "x", false)
  else
    vim.api.nvim_buf_call(buf, function()
      vim.api.nvim_feedkeys("q", "x", false)
    end)
  end
end

return M
