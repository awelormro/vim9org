" vim: set fdm=marker:
" Vimscript start {{{
if !has('vim9script')
function! Ntcodeblock(x)
  return synIDattr(synID(a:x, 1, 1), 'name') !=# 'OrgCodeBlock'
endfunction
function! OrgFolding() abort
  let line = getline(v:lnum)
  if line =~ '^\s*:PROPERTIES:$'
    return "a1"
  endif
  if line =~ '^\s*:END:$'
    return 's1'
  endif
  if line =~ "#+BEGIN_"
    return "a2"
  endif
  if line =~ "#+END_"
    return "s2"
  endif
  if line =~ " {{{"
    return "a1"
  endif
  if line =~ " }}}"
    return "s1"
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
  return "="
  return foldlevel(v:lnum-1)
  " if foldlevel(v:lnum-1) == 0
  "   return '='
  " else
  "   return foldlevel(v:lnum-1)
  " endif
endfunction

setlocal foldmethod=expr
setlocal foldexpr=OrgFolding()
" setlocal foldexpr=Orgfoldexpr
" setlocal foldexpr=OrgFoldingExpr()
finish
endif
" }}}
vim9script
# Vim9script start {{{
def OrgFold9s(lnum: number): string
  # echo 1
  var Ntcodeblock = (x) => synIDattr(synID(x, 1, 1), 'name') !=# 'OrgCodeBlock'
  var line = getline(v:lnum)
  var lnum_end = -10
  var nextline = getline(v:lnum + 1)
  if line =~# '^\s*:PROPERTIES:$'
    return "a7"
  elseif line =~# '^\s*:END:$'
    return 's7'
  elseif line =~# "#+BEGIN_"
    return "a7"
  elseif line =~# "#+END_"
    return "s7"
  elseif line =~# " {{{"
    return "a7"
  elseif line =~# " }}}"
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
  return "="
enddef


setlocal foldmethod=expr
setlocal foldexpr=OrgFold9s(v:lnum)
# }}}
