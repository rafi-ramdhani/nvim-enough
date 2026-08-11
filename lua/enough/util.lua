---@mod enough.util Small shared helpers.

local M = {}

--- Remove duplicates while preserving order.
---@param list string[]
---@return string[]
function M.uniq(list)
  local seen, out = {}, {}
  for _, item in ipairs(list) do
    if not seen[item] then
      seen[item] = true
      out[#out + 1] = item
    end
  end
  return out
end

return M
