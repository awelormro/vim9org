local M = {}

local function M.Ntcodeblock(x)
  return vim.fn.synIDattr(vim.fn.synID(x, 1, 1), "name") ~= "OrgCodeBlock"
end

local function M.OrgFolding()
  local line = vim.fn.getline(vim.v.lnum) -- Obtener la línea actual
  local nextline = vim.fn.getline(vim.v.lnum + 1) -- Obtener la línea siguiente

  if line:match("^%s*:PROPERTIES:$") then
    return "a7"
  end
  if line:match("^%s*:END:$") then
    return "s7"
  end
  if line:match("#%+BEGIN_") then
    return "a7"
  end
  if line:match("#%+END_") then
    return "s7"
  end
  if line:match(" {{{") then
    return "a7"
  end
  if line:match(" }}}") then
    return "s7"
  end
  if line:match("^%*+ ") and Ntcodeblock(vim.v.lnum) then
    return ">" .. (line:find(" ") or 0) -- Encontrar el primer espacio
  end
  if line:match("^.+$") and nextline:match("^=+$") and Ntcodeblock(vim.v.lnum + 1) then
    return ">1"
  end
  if line:match("^.+$") and nextline:match("^%-+$") and Ntcodeblock(vim.v.lnum + 1) then
    return ">2"
  end
  return "="
end

return M
