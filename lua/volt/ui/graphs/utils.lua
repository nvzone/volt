---@class volt.UI.Graphs.Utils
local M = {}

--- @param format fun(n: integer): fmt: string
--- @return { labels: string[], maxw: integer }
function M.gen_labels(format)
  local result, max_strw = {}, 0
  for i = 1, 10, 1 do
    local num = format and format(i * 10) or tostring(i * 10)
    if num:len() > max_strw then
      max_strw = num:len()
    end
    table.insert(result, num)
  end

  result = vim.tbl_map(function(x)
    return (" "):rep(max_strw - x:len()) .. x
  end, result)

  return { labels = result, maxw = max_strw + 1 }
end

---@param virt_txt string
---@param total_w integer
---@param l_pad integer
function M.footer_label(virt_txt, total_w, l_pad)
  local pad = math.floor((total_w / 2 + l_pad) - (vim.api.nvim_strwidth(virt_txt[1]) / 2))
  return { { (" "):rep(pad) }, virt_txt }
end

return M
