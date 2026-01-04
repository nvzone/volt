-- The MIT License (MIT)
--
-- Copyright (c) 2022 Leon Heidelbach
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- All credits to https://github.com/LeonHeidelbach for making this!
-- 90% of functions are written by him

local M = {}

-- Convert a hex color value to RGB
--- @param hex string: The hex color value
--- @return integer|nil r: Red (0-255)
--- @return integer|nil g: Green (0-255)
--- @return integer|nil b: Blue (0-255)
function M.hex2rgb(hex)
  local hash = string.sub(hex, 1, 1) == "#"
  if string.len(hex) ~= (7 - (hash and 0 or 1)) then
    return
  end

  local r = tonumber(hex:sub(2 - (hash and 0 or 1), 3 - (hash and 0 or 1)), 16)
  local g = tonumber(hex:sub(4 - (hash and 0 or 1), 5 - (hash and 0 or 1)), 16)
  local b = tonumber(hex:sub(6 - (hash and 0 or 1), 7 - (hash and 0 or 1)), 16)
  return r, g, b
end

-- Convert a hex color value to RGB ratio
--- @param hex string: The hex color value
--- @return integer r: Red (0-100)
--- @return integer g: Green (0-100)
--- @return integer b: Blue (0-100)
function M.hex2rgb_ratio(hex)
  local r, g, b = M.hex2rgb(hex)
  return math.floor(r / 255 * 100), math.floor(g / 255 * 100), math.floor(b / 255 * 100)
end

-- Convert an RGB color value to hex
--- @param r number: Red (0-255)
--- @param g number: Green (0-255)
--- @param b number: Blue (0-255)
--- @return string hex: The hexadecimal string representation of the color
function M.rgb2hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r), math.floor(g), math.floor(b))
end

-- Helper function to convert a HSL color value to RGB
-- Not to be used directly, use M.hsl2rgb instead
--- @param p number
--- @param q number
--- @param a number
--- @return number
function M.hsl2rgb_helper(p, q, a)
  if a < 0 then
    a = a + 6
  end
  if a >= 6 then
    a = a - 6
  end
  if a < 1 then
    return (q - p) * a + p
  end
  if a < 3 then
    return q
  end
  if a < 4 then
    return (q - p) * (4 - a) + p
  end

  return p
end

-- Convert a HSL color value to RGB
--- @param h number: Hue (0-360)
--- @param s number: Saturation (0-1)
--- @param l number: Lightness (0-1)
--- @return integer r: Red (0-255)
--- @return integer g: Green (0-255)
--- @return integer b: Blue (0-255)
function M.hsl2rgb(h, s, l)
  local t1, t2, r, g, b

  if l <= 0.5 then
    t2 = l * (s + 1)
  else
    t2 = l + s - (l * s)
  end

  h = h / 60
  t1 = l * 2 - t2
  r = M.hsl2rgb_helper(t1, t2, h + 2) * 255
  g = M.hsl2rgb_helper(t1, t2, h) * 255
  b = M.hsl2rgb_helper(t1, t2, h - 2) * 255

  return math.floor(r), math.floor(g), math.floor(b)
end

-- Convert an RGB color value to HSL
--- @param r number: Red (0-255)
--- @param g number: Green (0-255)
--- @param b number: Blue (0-255)
--- @return number h: Hue (0-360)
--- @return number s: Saturation (0-1)
--- @return number l: Lightness (0-1)
function M.rgb2hsl(r, g, b)
  local min, max, l, s, maxcolor, h
  r, g, b = r / 255, g / 255, b / 255

  min = math.min(r, g, b)
  max = math.max(r, g, b)
  maxcolor = 1 + (max == b and 2 or (max == g and 1 or 0))

  if maxcolor == 1 then
    h = (g - b) / (max - min)
  elseif maxcolor == 2 then
    h = 2 + (b - r) / (max - min)
  elseif maxcolor == 3 then
    h = 4 + (r - g) / (max - min)
  end

  if not rawequal(type(h), "number") then
    h = 0
  end

  h = h * 60

  if h < 0 then
    h = h + 360
  end

  l = (min + max) / 2

  if min == max then
    s = 0
  else
    if l < 0.5 then
      s = (max - min) / (max + min)
    else
      s = (max - min) / (2 - max - min)
    end
  end

  return h, s, l
end

-- Convert a hex color value to HSL
--- @param hex string: The hex color value
--- @return number h: Hue (0-360)
--- @return number s: Saturation (0-1)
--- @return number l: Lightness (0-1)
function M.hex2hsl(hex)
  local r, g, b = M.hex2rgb(hex)
  return M.rgb2hsl(r, g, b)
end

-- Convert a HSL color value to hex
--- @param h number: Hue (0-360)
--- @param s number: Saturation (0-1)
--- @param l number: Lightness (0-1)
--- @return string hex: The hex color value
function M.hsl2hex(h, s, l)
  local r, g, b = M.hsl2rgb(h, s, l)
  return M.rgb2hex(r, g, b)
end

-- Change the hue of a color by a given amount
--- @param hex string: The hex color value
--- @param percent integer: The amount to change the hue
--- @return string hex: The hex color value
function M.change_hex_hue(hex, percent)
  local h, s, l = M.hex2hsl(hex)
  -- Convert percentage to a degree shift
  local shift = (percent / 100) * 360
  h = (h + shift) % 360
  if h < 0 then
    h = h + 360
  end
  return M.hsl2hex(h, s, l)
end

-- Desaturate or saturate a color by a given percentage
--- @param hex string: The hex color value
--- @param percent number: The percentage to desaturate or saturate the color.
--- @return string hex: The hex color value
function M.change_hex_saturation(hex, percent)
  local h, s, l = M.hex2hsl(hex)
  s = s + (percent / 100)
  if s > 1 then
    s = 1
  end
  if s < 0 then
    s = 0
  end
  return M.hsl2hex(h, s, l)
end

-- Lighten or darken a color by a given percentage
--- @param hex string: The hex color value
--- @param percent number: The percentage to lighten or darken the color.
--- @return string hex: The hex color value
function M.change_hex_lightness(hex, percent)
  local h, s, l = M.hex2hsl(hex)
  l = l + (percent / 100)
  if l > 1 then
    l = 1
  end
  if l < 0 then
    l = 0
  end
  return M.hsl2hex(h, s, l)
end

-- Compute a gradient between two colors
--- @param hex1 string: The first hex color value
--- @param hex2 string: The second hex color value
--- @param steps integer: The number of steps to compute
--- @return string[] gradient: A table of hex color values
function M.compute_gradient(hex1, hex2, steps)
  local h1, s1, l1 = M.hex2hsl(hex1)
  local h2, s2, l2 = M.hex2hsl(hex2)
  local h, s, l
  local h_step = (h2 - h1) / (steps - 1)
  local s_step = (s2 - s1) / (steps - 1)
  local l_step = (l2 - l1) / (steps - 1)
  local gradient = {}

  for i = 0, steps - 1 do
    h = h1 + (h_step * i)
    s = s1 + (s_step * i)
    l = l1 + (l_step * i)
    gradient[i + 1] = M.hsl2hex(h, s, l)
  end

  return gradient
end

-- Generate complementary colors
--- @param hex string: The hex color value (string)
--- @param count integer: The number of complementary colors to generate
--- @return string[] complementary_colors: A table containing the complementary colors in hex format
function M.hex2complementary(hex, count)
  local h, s, l = M.hex2hsl(hex)
  local complementary_colors = {}

  -- Calculate the hue for the complementary color (180 degrees shift)
  local complementary_hue = (h + 180) % 360

  -- Create a gradient of colors by slightly varying the complementary hue
  local hue_step = 360 / count
  for i = 0, count - 1 do
    local new_hue = (complementary_hue + (hue_step * i)) % 360
    local complementary_hex = M.hsl2hex(new_hue, s, l)
    table.insert(complementary_colors, complementary_hex)
  end

  return complementary_colors
end

-- Mix two colors with a given percentage.
--- @param first string: The primary hex color.
--- @param second string: The hex color you want to mix into the first color.
--- @param strength number: The percentage of second color in the output (0-100).
--- @return string mixed: The mixed color as a hex value
function M.mix(first, second, strength)
  if strength == nil then
    strength = 0.5
  end

  local s = strength / 100
  local r1, g1, b1 = M.hex2rgb(first)
  local r2, g2, b2 = M.hex2rgb(second)

  if r1 == nil or r2 == nil then
    return first
  end

  if s == 0 then
    return first
  end
  if s == 1 then
    return second
  end

  local r3 = r1 * (1 - s) + r2 * s
  local g3 = g1 * (1 - s) + g2 * s
  local b3 = b1 * (1 - s) + b2 * s

  return M.rgb2hex(r3, g3, b3)
end

return M
