" vim: set fdm=marker:
if !has('vim9script') || g:org_vim9_disabled
  " Declare variables before start indent {{{
  if exists("b:did_indent")
    finish
  endif
  let s:cpo_save = &cpo
  set cpo&vim

  if !exists("g:org_indent_items")
    let g:org_indent_items = 1
  endif

  if !exists("g:org_indent_after_headings")
    let g:org_indent_after_headings = 1
  endif
  " }}}
  " Vim settings {{{
  setlocal autoindent
  setlocal nosmartindent
  setlocal indentexpr=GetOrgIndent()
  setlocal indentkeys&
  " setlocal indentkeys+=
  " }}}
  " Start Example function {{{
  function! GetOrgIndent()
    " Find non blank line above the current
    let lnum = prevnonblank(v:lnum -1)
    let cnum = v:lnum
    " Start of file with zero indent
    if lnum == 0
      return 0
    endif
    let line = substitute(getline(lnum), '\s*%.*', '', 'g') " Last line
    let cline = substitute(getline(v:lnum), '\s*%.*', '', 'g') " Current line
    let ccol =  indent(line(cnum))
    " Start to check all the conditions to generate the indentation
    " CheckBox Indent
    if line =~ '^\s*- \['
      return indent(v:lnum - 1)+6
    " Lists Indent
    elseif line =~ '^\s*-'
      return indent(v:lnum - 1)+2
    elseif line =~ '^\s*\*\s'
      return indent(v:lnum - 1)+2
    elseif line =~ '^\s*+\s'
      return indent(v:lnum - 1)+2
    " Headers Indent
    elseif line =~ '^\*\s'
      return indent(v:lnum - 1)+2
    elseif line =~ '^\*\*\s'
      return indent(v:lnum - 1)+3
    elseif line =~ '^\*\*\*\s'
      return indent(v:lnum - 1)+4
    elseif line =~ '^\*\*\*\*\s'
      return indent(v:lnum - 1)+5
    elseif line =~ '^\*\*\*\*\*\s'
      return indent(v:lnum - 1)+6
    elseif line =~ '^\*\*\*\*\*\*\s'
      return indent(v:lnum - 1)+7
    elseif line =~ '^\s*\d*\.\s'
      return indent(v:lnum - 1)+3
    elseif line =~ '^\s*\d*)\s'
      return indent(v:lnum - 1)+3
    elseif line =~ '^\s*\a*\.\s'
      return indent(v:lnum - 1)+3
    elseif line =~ '^\s*\a*)\s'
      return indent(v:lnum - 1)+3
    else
      return indent(v:lnum - 1)
    endif
  endfunction
  " }}}
  finish
endif

vim9script

# Declare variables before start indent {{{
if exists("b:did_indent")
  finish
endif
b:did_indent = true
var undo_opts = "setl indentexpr< indentkeys< lisp< autoindent<"

if exists('b:undo_indent')
    b:undo_indent ..= "|" .. undo_opts
else
    b:undo_indent = undo_opts
endif
# var s:cpo_save = &cpo
# set cpo&vim

if !exists("g:org_indent_items")
  g:org_indent_items = 1
endif

if !exists("g:org_indent_after_headings")
  g:org_indent_after_headings = 1
endif
# }}}
# Vim settings {{{
# setlocal indentkeys+=
# }}}
# Start Example function {{{

setlocal autoindent
setlocal nolisp
setlocal nosmartindent

g:loadedorgindent = 1
# setlocal indentkeys
# setlocal indentexpr=GetOrgIndent(v:lnum)
# # }}}  
# Start function {{{
def GetOrgIndent(lnum: number): number
  g:loadedorgindent = 1
  if lnum == 0
    return 0
  endif
  # Previous line data
  var plnum = prevnonblank(lnum)
  var pline = getline(plnum)
  var plindent = indent(plnum)
  # Current line data
  var inden = 0
  if pline =~ '^\s*- '
    inden = plindent + 6
  if pline =~ '^\s*- \[' && pline = '^\s*- '
    inden = plindent + 6
  else
    inden =
  endif
  b:localind = inden
  " echo plnum
  inden = 99
  return inden
  # echo inden
enddef

# # }}}  
# # Previous file indent attempt {{{
# # Find non blank line above the current
# var lnum = prevnonblank(lnum - 1)
# # echo lnum
# var cnum = lnum
# # echo cnum
# # Start of file with zero indent
# if lnum == 0
#   return 0
# endif
# var line = substitute(string(getline(lnum)), '\s*%.*', '', 'g') # Last line
# # echo line
# # echo line
# var cline = substitute(string(getline(v:lnum)), '\s*%.*', '', 'g') # Current line
# # echo cline
# # var ccol =  indent(line(cnum))
# # echo ccol
# # Start to check all the conditions to generate the indentation
# # CheckBox Indent
# # echo line =~ '^\s*- \['
# if line =~ '^\s*- \['
#   echo 'CheckBox'
#   return indent(v:lnum - 1) + 6
# # Lists Indent
# elseif line =~? '^\s*-'
#   echo 'list'
#   return indent(v:lnum - 1) + 2
# elseif line =~ '^\s*\*\s'
#   echo 'list'
#   return indent(v:lnum - 1) + 2
# elseif line =~ '^\s*+\s'
#   return indent(v:lnum - 1) + 2
# # Headers Indent
# elseif line =~ '^\*\s'
#   echo 'header'
#   return indent(v:lnum - 1) + 2
# elseif line =~ '^\*\*\s'
#   return indent(v:lnum - 1) + 3
# elseif line =~ '^\*\*\*\s'
#   return indent(v:lnum - 1) + 4
# elseif line =~ '^\*\*\*\*\s'
#   return indent(v:lnum - 1) + 5
# elseif line =~ '^\*\*\*\*\*\s'
#   return indent(v:lnum - 1) + 6
# elseif line =~ '^\*\*\*\*\*\*\s'
#   return indent(v:lnum - 1) + 7
# elseif line =~ '^\s*\d*\.\s'
#   return indent(v:lnum - 1) + 3
# elseif line =~ '^\s*\d*)\s'
#   return indent(v:lnum - 1) + 3
# elseif line =~ '^\s*\a*\.\s'
#   return indent(v:lnum - 1) + 3
# elseif line =~ '^\s*\a*)\s'
#   return indent(v:lnum - 1) + 3
# else
#   echo 'Non used'
#   return indent(v:lnum - 1)
# endif
# # echo 'nonused lol'
# # }}}  
