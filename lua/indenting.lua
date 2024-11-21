-- vim: set nospell:
-- vim: set tabstop=2:
local M = {}

function M.GetLuaIndent()
  local indent = 99
  local contprev = vim.eval("getline(v:lnum-1)") -- Contenido de la línea anterior
  local indentprev = #(contprev:match("^%s*"))
  if type(contprev) == "string" and contprev:match("^%s*%- %[") then
    indent = indentprev + 6
  elseif type(contprev) == "string" and contprev:match("^%s*%- ") then
    indent = indentprev + 2
  elseif type(contprev) == "string" and contprev:match("^%* ") then
    indent = 2
  elseif type(contprev) == "string" and contprev:match("^%*%* ") then
    indent = 3
  elseif type(contprev) == "string" and contprev:match("^%*%*%* ") then
    indent = 4
  elseif type(contprev) == "string" and contprev:match("^%*%*%*%* ") then
    indent = 5
  elseif type(contprev) == "string" and contprev:match("^%*%*%*%*%* ") then
    indent = 6
  elseif type(contprev) == "string" and contprev:match("^%s.") then
    indent = indentprev
  else
    indent = indentprev
  end

  return indent
end


function M.GetPrevHeader()
  local linenum = vim.fn.line('.')
  local linecont = vim.fn.getline(linenum)
  while linenum > 0 do
    if linecont:match("^%* ") then
      previndent = 2
      break
    elseif linecont:match("^%*%* ") then
      previndent = 3
      break
    elseif linecont:match("^%*%*%* ") then
      previndent = 4
      break
    elseif linecont:match("^%*%*%*%* ") then
      previndent = 5
      break
    elseif linecont:match("^%*%*%*%*%* ") then
      previndent = 6
      break
    else
      linenum = linenum - 1 
    end
  end
end


function M.GetLuaIndentNvim(contline)
  contprev = vim.fn.getline(vim.v['lnum'] - 1)
  local indentprev = #(contprev:match("^%s*"))
  if contprev:match("^%* ") then
    previndent = 2
    return 2
  elseif type(contprev) == "string" and contprev:match("^%*%* ") then
    previndent = 3
    return 3
  elseif type(contprev) == "string" and contprev:match("^%*%*%* ") then
    previndent = 4
    return 4
  elseif type(contprev) == "string" and contprev:match("^%*%*%*%* ") then
    previndent = 5
    return 5
  elseif type(contprev) == "string" and contprev:match("^%*%*%*%*%* ") then
    previndent = 6
    return 6
  elseif type(contprev) == "string" and contprev:match("^%s*%- %[") then
    return indentprev + 6
  elseif type(contprev) == "string" and contprev:match("^%s*%- ") then
    return indentprev + 2
  elseif type(contprev) == "string" and contprev:match("^%s*%+ ") then
    return indentprev + 2
  elseif type(contprev) == "string" and contprev:match("^%s*.") then
    return indentprev
  else
    return previndent
  end
end
return M
