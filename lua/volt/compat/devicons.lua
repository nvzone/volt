-- lua/volt/compat/devicons.lua
-- Backwards compatibility shim that mimics the minimal nvim-web-devicons API

local icons = require "volt.icons"

local M = {}

-- Mimic nvim-web-devicons.get_icon(filename, extension, opts)
function M.get_icon(name, ext, opts)
  local icon, color, hl_name = icons.get_icon(name, ext)
  local hl = "VoltIcon" .. (hl_name or "Default")
  return icon, hl
end

-- Minimal get_icon_color(filename, extension)
function M.get_icon_color(name, ext, opts)
  local _, color = icons.get_icon(name, ext)
  return color
end

-- Provide a filetype-based helper (best-effort)
function M.get_icon_by_filetype(ft, opts)
  return M.get_icon(ft, ft, opts)
end

function M.setup(opts)
  -- noop: Volt manages icons internally
end

return M
