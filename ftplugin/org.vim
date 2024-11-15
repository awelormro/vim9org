" vim: set fdm=marker:
" vim: set nospell:
" Start all before vim9script {{{ 

if !has('vim9script') || g:org_backend != 'vim9script'
  if !exists('b:current_syntax')
    finish
  endif
  let b:current_syntax = 'org'
  if g:org_backend == 'python'
    python3 import starter
    py3 import folding
    python3 starter.StartOrgpy()
    set foldmethod=expr
    " set foldexpr=OrgFoldWithPython()
    set foldexpr=OrgFolding1()
  elseif g:org_backend == 'lua' 
    echo 'will act in lua'
  elseif g:org_backend == 'legacy'
    echo 'Will act as vimscript'
  else
    echo 'Will act as vimscript'
  endif
  " Folding function in vimscript {{{ 
  " 
  function! Ntcodeblock(x)
    return synIDattr(synID(a:x, 1, 1), 'name') !=# 'OrgCodeBlock'
  endfunction
  function! OrgFolding1() abort
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
  finish
endif " }}}
vim9script 
# {{{
import autoload "starters/startvim9.vim" as vim9start
vim9start.Startvim9()
# }}}
