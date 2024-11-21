" vim: set nospell:
" vim: set foldmethod=marker:


function! indenting#OrgIndenter() " {{{
  let pline = getline(v:lnum - 1)
  let level = indent(pline)
  if pline =~ '^\s*- \['
    return level + 6
  elseif pline =~ '^\s*\d[\.\)] '
    return level + 3
  elseif pline =~ '^\s*[0-9i]\{2}[\.\)] '
    return level + 4
  elseif pline =~ '^\s*\d\d\d[\.\)] '
    return level + 5
  elseif pline =~ '^\s*\a[\.\)]\s'
    return level + 3
  elseif pline =~ '^\* '
    return 2
  elseif pline =~ '^\*\* '
    return 3
  elseif pline =~ '^\*\*\* '
    return 4
  elseif pline =~ '^\*\*\*\* '
    return 5
  elseif pline =~ '^\*\*\*\*\* '
    return 6
  elseif pline =~ '^\*\*\*\*\*\* '
    return 7
  elseif pline =~ '^\s*[+-\*] '
    return level + 2
  endif
  return level
endfunction " }}}


function! indenting#GetOrgIndentWithPython() abort " {{{
  python3 import indenting
  let retval = str2nr(py3eval('indenting.IndentVimWithPython()'))
  return retval
endfunction " }}}


function! indenting#ResetOrgHeading() abort " {{{
  py3 import indenting
  py3 indenting.RestoreHeaderLevel()
endfunction " }}}


function! indenting#GetOrgIndentWithLua() abort " {{{ 
  lua require('indenting')
  let luaevaluation = luaeval('require("indenting").GetLuaIndentNvim()')
  return luaevaluation
endfunction " }}}


function! indenting#ResetOrgHeadingLua() abort " {{{
  lua require("indenting")
  luaeval('require("indenting").GetPrevHeader()')
endfunction " }}}
