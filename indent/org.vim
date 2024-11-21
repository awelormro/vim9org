" vim: set foldmethod=marker: 
" vim: set nospell:
" Vim indent plugin file
" Language: Org
" Maintainer: Marco Antonio Romero  <chupermarco619@gmail.com>
" Website: https://github.com/awelormro/vim9org
" Last Change: 2024-10-06
" Checker for neovim {{{
if has('nvim')
  if exists("b:did_indent")
    finish
  endif
  let b:did_indent = 1
  let b:undo_indent = 'setlocal indentexpr< autoindent<'
  setlocal autoindent
  setlocal nosmartindent
  finish
" }}}
" Checker for old vim or external engines {{{
elseif v:version < 900
  if exists("b:did_indent")
    finish
  endif
  let b:did_indent = 1
  let b:undo_indent = 'setlocal indentexpr< autoindent<'
  setlocal autoindent
  setlocal nosmartindent
  setlocal autoindent
  setlocal nosmartindent
  finish
elseif !exists('g:org_backend') || g:org_backend != 'vim9script'
  if exists("b:did_indent")
    finish
  endif
  let b:did_indent = 1
  let b:undo_indent = 'setlocal indentexpr< autoindent<'
  setlocal autoindent
  setlocal nosmartindent
  finish
endif " }}}
vim9script

# Important variables for indenting {{{
if exists("b:did_indent")
    finish
endif
b:did_indent = 1

b:undo_indent = 'setlocal indentexpr< autoindent<'


# }}}
def GetOrgIndent(lnum: number): number # {{{
  var ind: number = lnum
  var plnum: number = prevnonblank(lnum - 1)
  var pline: string = getline(lnum - 1)
  var pind: number = indent(plnum)
  var level: number = pind
  var prevstart: number = b:org_heading_actuallevel
  if pline =~ '^\s*- \['
    return level + 6
  elseif pline =~ '^\s*[+-\*] '
    return level + 2
  # TODO: Add conditional for count decimals and adjust level
  elseif pline =~ '^\s*\d[\.\)] '
    return level + 3
  elseif pline =~ '^\s*[0-9i]\{2}[\.\)] '
    return level + 4
  elseif pline =~ '^\s*\d\d\d[\.\)] '
    return level + 5
  elseif pline =~ '\M^\s*\a\.\s'
    return level + 3
  elseif pline =~ '^\* '
    return level + 2
  elseif pline =~ '^\*\* '
    return level + 3
  elseif pline =~ '^\*\*\* '
    return level + 4
  elseif pline =~ '^\*\*\*\* '
    return level + 5
  elseif pline =~ '^\*\*\*\*\* '
    return level + 6
  elseif pline =~ '^\*\*\*\*\*\* '
    return level + 7
  endif
  return level
enddef # }}}
# Indent formatting {{{
setlocal autoindent
setlocal nosmartindent
setlocal indentexpr=GetOrgIndent(v:lnum)


# }}}
def PrevLine(lnum: number): number # {{{
    var plnum = lnum - 1
    var pline: string
    while plnum > 1
        plnum = prevnonblank(plnum)
        pline = getline(plnum)
        # XXX: take into account nested multiline /* /* */ */ comments
        if pline =~ '\*/\s*$'
            while getline(plnum) !~ '/\*' && plnum > 1
                plnum -= 1
            endwhile
            if getline(plnum) =~ '^\s*/\*'
                plnum -= 1
            else
                break
            endif
        elseif pline =~ '^\s*//'
            plnum -= 1
        else
            break
        endif
    endwhile
    return plnum
enddef # }}}
