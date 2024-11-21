function! Ntcodeblock(x)
  return synIDattr(synID(a:x, 1, 1), 'name') !=# 'OrgCodeBlock'
endfunction
function! OrgFolding() abort
  let line = getline(v:lnum)
  if line =~ '^\s*:PROPERTIES:$'
    return "a7"
  endif
  if line =~ '^\s*:END:$'
    return 's7'
  endif
  if line =~ "#+BEGIN_"
    return "a7"
  endif
  if line =~ "#+END_"
    return "s7"
  endif
  if line =~ " {{{"
    return "a7"
  endif
  if line =~ " }}}"
    return "s7"
  endif
  if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
    return ">" .. match(line, ' ')
  endif
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
    return ">1"
  endif 
  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
    return ">2"
  endif
  return '='
endfunction
" }}}
" Attempt to use python {{{
function! OrgFoldWithPython() abort
  python3 import folding
  let stringback = py3eval('folding.OrgFolding()')
  return stringback
endfunction
" }}}
" Attempt to use lua {{{
function! OrgFoldWithLua() abort
  lua require('folding')
  let luaevaluation = luaeval('require("folding").OrgFolding()')
  return luaevaluation
endfunction  
" }}}
