local nvmark_state = require("volt.state")
local MouseMove = vim.keycode("<MouseMove>")
local LeftMouse = vim.keycode("<LeftMouse>")

---@param n integer
local function get_item_from_col(tb, n)
  for _, val in ipairs(tb) do
    if val.col_start <= n and val.col_end >= n then
      return val
    end
  end
end

--- @param foo function|string
local function run_func(foo)
  if type(foo) == "function" then
    foo()
  elseif type(foo) == "string" then
    vim.cmd(foo)
  end
end

---@param buf integer
---@param by? string
---@param row? integer
---@param col? integer
---@param win? integer
local function handle_click(buf, by, row, col, win)
  if not row then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    row, col = cursor_pos[1], cursor_pos[2]
  end

  local v = nvmark_state[buf]
  if v.clickables[row] then
    local virt = get_item_from_col(v.clickables[row], col)
    if virt and (by ~= "keyb" or virt.ui_type == "slider") then
      local actions = virt.actions
      run_func(type(actions) == "table" and actions.click or actions)
    end

    if win and vim.api.nvim_win_is_valid(win) then
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(win, { 1, 1 })
      end)
    end
  end
end

---@param buf integer
local function set_cursormoved_autocmd(buf)
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      handle_click(buf, "keyb")
    end,
  })
end

--- @param buf_state Volt.State
--- @param buf integer
--- @param row integer
--- @param col integer
local function handle_hover(buf_state, buf, row, col)
  -- clear old hovers!
  if buf_state.hovered_extmarks then
    vim.g.nvmark_hovered = nil
    require("volt").redraw(buf, buf_state.hovered_extmarks)
    buf_state.hovered_extmarks = nil
  end

  if buf_state.hoverables[row] then
    local virt = get_item_from_col(buf_state.hoverables[row], col)
    if virt and virt.hover then
      if virt.hover.callback then
        virt.hover.callback()
      end

      vim.g.nvmark_hovered = virt.hover.id or nil
      require("volt").redraw(buf, virt.hover.redraw)
      buf_state.hovered_extmarks = virt.hover.redraw
    end
  end
end

--- @param buf integer
local function buf_mappings(buf)
  set_cursormoved_autocmd(buf)

  vim.keymap.set("n", "<CR>", function()
    handle_click(buf)
  end, { buffer = buf })

  vim.keymap.set("n", "<Tab>", function()
    require("volt.utils").cycle_clickables(buf, 1)
  end, { buffer = buf })

  vim.keymap.set("n", "<S-Tab>", function()
    require("volt.utils").cycle_clickables(buf, -1)
  end, { buffer = buf })
end

---@class volt.Events
---@field bufs integer[]
local M = {}

M.bufs = {}

---@param val integer[]|integer
function M.add(val)
  if type(val) == "table" then
    for _, buf in ipairs(val) do
      table.insert(M.bufs, buf)
      buf_mappings(buf)
    end
    return
  end

  table.insert(M.bufs, val)
  buf_mappings(val)
end

function M.enable()
  vim.g.extmarks_events = true
  vim.o.mousemev = true

  vim.on_key(function(key)
    local mousepos = vim.fn.getmousepos()
    local cur_win = mousepos.winid
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)

    if vim.tbl_contains(M.bufs, cur_buf) then
      local row, col = mousepos.line, mousepos.column - 1

      if key == MouseMove then
        handle_hover(nvmark_state[cur_buf], cur_buf, row, col)
      elseif key == LeftMouse then
        handle_click(cur_buf, "mouse", row, col, cur_win)
      end
    end
  end)
end

return M
