-- lua/volt/icons.lua
-- Minimal, cache-friendly icon provider with optional lazy full-set loader

local M = {}

-- Icon cache for performance
local icon_cache = {}

-- Lightweight icon data (commonly used)
local icons_by_extension = {
  lua = { icon = "", color = "#51A0CF", name = "Lua" },
  js  = { icon = "", color = "#EAD41C", name = "JavaScript" },
  ts  = { icon = "", color = "#2b7489", name = "TypeScript" },
  py  = { icon = "", color = "#3572A5", name = "Python" },
  md  = { icon = "", color = "#083fa1", name = "Markdown" },
  rs  = { icon = "", color = "#dea584", name = "Rust" },
  go  = { icon = "", color = "#00ADD8", name = "Go" },
  toml= { icon = "", color = "#9c4221", name = "TOML" },
  json= { icon = "ﬥ", color = "#cbcb41", name = "JSON" },
  sh  = { icon = "", color = "#6e4a7e", name = "Shell" },
}

local icons_by_filename = {
  [".gitignore"] = { icon = "", color = "#F54D27", name = "GitIgnore" },
  ["Makefile"]   = { icon = "", color = "#6D8086", name = "Makefile" },
  ["Dockerfile"] = { icon = "", color = "#0db7ed", name = "Dockerfile" },
  ["README.md"]  = { icon = "", color = "#083fa1", name = "Readme" },
  ["LICENSE"]    = { icon = "", color = "#6d8086", name = "License" },
  ["package.json"]= { icon = "", color = "#cbcb41", name = "Npm" },
  ["tsconfig.json"]= { icon = "", color = "#2b7489", name = "TSConfig" },
  ["Cargo.toml"] = { icon = "", color = "#dea584", name = "Cargo" },
  [".env"]       = { icon = "", color = "#4f5d95", name = "Env" },
  ["init.lua"]   = { icon = "", color = "#51A0CF", name = "LuaInit" },
}

-- Default fallback icon
local default_icon = {
  icon = "",
  color = "#6d8086",
  name = "Default"
}

function M.get_icon(name, ext)
  local cache_key = (name or "") .. ":" .. (ext or "")
  if icon_cache[cache_key] then
    return unpack(icon_cache[cache_key])
  end

  local icon_data

  -- filename match (case-insensitive)
  if name then
    local lname = name:lower()
    icon_data = icons_by_filename[lname]
  end

  -- extension match
  if not icon_data and ext and ext ~= "" then
    local lext = ext:lower()
    icon_data = icons_by_extension[lext]
  end

  icon_data = icon_data or default_icon

  icon_cache[cache_key] = { icon_data.icon, icon_data.color, icon_data.name }
  return icon_data.icon, icon_data.color, icon_data.name
end

-- Lazy loading for full icon set
function M.load_full_icons()
  if M.full_icons_loaded then return end

  local ok, full_icons = pcall(require, "volt.icons.full")
  if ok and full_icons then
    if full_icons.by_extension then
      icons_by_extension = vim.tbl_extend("force", icons_by_extension, full_icons.by_extension)
    end
    if full_icons.by_filename then
      icons_by_filename = vim.tbl_extend("force", icons_by_filename, full_icons.by_filename)
    end
    -- clear cache so new icons are picked up
    icon_cache = {}
  end

  M.full_icons_loaded = true
end

-- Utility to get icon with highlight group
function M.get_icon_with_hl(name, ext)
  local icon, color, hl_name = M.get_icon(name, ext)
  if color then
    local safe_name = (hl_name or "Default"):gsub("%s+", "")
    local hl_group = "VoltIcon" .. safe_name
    -- set highlight (idempotent)
    pcall(vim.api.nvim_set_hl, 0, hl_group, { fg = color })
    return icon, hl_group
  end
  return icon, nil
end

return M
