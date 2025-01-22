local api = vim.api
local lighten = require("volt.color").change_hex_lightness
local bg = vim.o.bg

local highlights = {}

local hexadecimal_to_hex = function(hex)
  return "#" .. ("%06x"):format((hex == nil and 0 or hex))
end

if vim.g.base46_cache then
  local colors = dofile(vim.g.base46_cache .. "colors")

  highlights = {
    ExDarkBg = { bg = colors.darker_black },
    ExDarkBorder = { bg = colors.darker_black, fg = colors.darker_black },

    ExBlack2Bg = { bg = colors.black2 },
    ExBlack2border = { bg = colors.black2, fg = colors.black2 },

    ExRed = { fg = colors.red },
    ExYellow = { fg = colors.yellow },
    ExBlue = { fg = colors.blue },
    ExGreen = { fg = colors.green },

    ExBlack3Bg = { bg = colors.one_bg2 },
    ExBlack3Border = { bg = colors.one_bg2, fg = colors.one_bg2 },
    ExLightGrey = { fg = lighten(colors.grey, bg == "dark" and 35 or -35) },
    CommentFg = { fg = colors.light_grey },
  }
else
  local normal_bg = api.nvim_get_hl(0, { name = "Normal" }).bg
  local comment_fg = api.nvim_get_hl(0, { name = "comment" }).fg

  normal_bg = hexadecimal_to_hex(normal_bg)
  comment_fg = hexadecimal_to_hex(comment_fg)

  local darker_bg = lighten(normal_bg, -3)
  local lighter_bg = lighten(normal_bg, 5)
  local black3_bg = lighten(normal_bg, 10)

  local get_hl = function(name)
    local data = api.nvim_get_hl(0, { name = name })
    return hexadecimal_to_hex(data.fg)
  end

  highlights = {
    ExDarkBg = { bg = darker_bg },
    ExDarkBorder = { bg = darker_bg, fg = darker_bg },

    ExBlack2Bg = { bg = lighter_bg },
    ExBlack2Border = { bg = lighter_bg, fg = lighter_bg },

    ExRed = { fg = get_hl "removed" },
    ExYellow = { fg = get_hl "changed" },
    ExBlue = { fg = get_hl "Function" },
    ExGreen = { fg = get_hl "added" },
    ExBlack3Bg = { bg = black3_bg },
    CommentFg = { fg = comment_fg },
    ExBlack3Border = { bg = black3_bg, fg = black3_bg },
    ExLightGrey = { fg = lighten(comment_fg, bg == "dark" and 20 or -20) },
  }
end

for name, val in pairs(highlights) do
  vim.api.nvim_set_hl(0, name, val)
end
