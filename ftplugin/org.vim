" vim: set nospell:
" vim: set foldmethod=marker:
" Selectors previously to vim9script {{{
if has('nvim')
  call vimlegacy#orgstarters#Vimscriptstart()
  setlocal foldexpr=OrgFolding()
  if has('python3') && g:org_backend == 'python'
    command -buffer OrgRestoreHead  call indenting#ResetOrgHeading()
    " setlocal foldexpr=OrgFoldWithPython()
    setlocal indentexpr=indenting#GetOrgIndentWithPython()
  elseif g:org_backend == 'lua'
    lua previndent = 0
    setlocal indentexpr=indenting#GetOrgIndentWithLua()
  else
    setlocal indentexpr=indenting#OrgIndenter()
  endif
  finish
elseif v:version < 900
  call vimlegacy#orgstarters#Vimscriptstart()
  setlocal foldexpr=OrgFolding()
  if has('python3') && g:org_backend == 'python'
    command -buffer OrgRestoreHead  call indenting#ResetOrgHeading()
    " setlocal foldexpr=OrgFoldWithPython()
    setlocal indentexpr=indenting#GetOrgIndentWithPython()
  elseif has('lua') && g:org_backend == 'lua'
    lua previndent = 0
    setlocal indentexpr=indenting#GetOrgIndentWithLua()
  else
    " setlocal foldexpr=OrgFolding()
    setlocal indentexpr=indenting#OrgIndenter()
  endif
  finish
elseif exists('g:org_backend') && g:org_backend != 'vim9script'
  call vimlegacy#orgstarters#Vimscriptstart()
  setlocal foldexpr=OrgFolding()
  if has('python3') && g:org_backend == 'python'
    command -buffer OrgRestoreHead  call indenting#ResetOrgHeading()
    " setlocal foldexpr=OrgFoldWithPython()
    setlocal indentexpr=indenting#GetOrgIndentWithPython()
  elseif has('lua') && g:org_backend == 'lua'
    lua previndent = 0
    setlocal indentexpr=indenting#GetOrgIndentWithLua()
  else
    " setlocal foldexpr=OrgFolding()
    setlocal indentexpr=indenting#OrgIndenter()
  endif
  finish
endif
" }}}
vim9script
# Vim9script add starters and import stuff {{{
import autoload 'vim9/starter9org.vim' as startorg
g:org_backend = 'vim9script'
b:current_syntax = 'org'
startorg.Starter9org()


# }}}
# Vim9script fold function {{{


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
