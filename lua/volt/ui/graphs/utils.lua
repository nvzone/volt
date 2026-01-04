local M = {}

--- @param format nil|fun(n: integer): string
function M.gen_labels(format)
  local result = {}
  local max_strw = 0

  for i = 1, 10, 1 do
    local num

    if format then
      num = format(i * 10)
    else
      num = tostring(i * 10)
    end

    if num:len() > max_strw then
      max_strw = #num
    end

    table.insert(result, num)
  end

  result = vim.tbl_map(function(x)
    return string.rep(" ", max_strw - #x) .. x
  end, result)

  return { labels = result, maxw = max_strw + 1 }
end

function M.footer_label(virt_txt, total_w, l_pad)
  local strw = vim.api.nvim_strwidth(virt_txt[1]) / 2
  local pad = (total_w / 2 + l_pad) - strw
  return { { string.rep(" ", pad) }, virt_txt }
end

return M
