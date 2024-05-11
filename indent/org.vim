vim9script

# Vim indent plugin file
# Language: Odin
# Maintainer: Maxim Kim <habamax@gmail.com>
# Website: https://github.com/habamax/vim-odin
# Last Change: 2024-01-15

if exists("b:did_indent")
    finish
endif
b:did_indent = 1

b:undo_indent = 'setlocal autoindent< indentexpr<'

setlocal autoindent
setlocal nosmartindent
# setlocal cindent
# setlocal cinoptions=L0,m1,(s,j1,J1,l1,+0,:0,#3
# setlocal cinkeys=0-,0},0),0],!^F,:,o,O

setlocal indentexpr=GetOrgIndent(v:lnum)

def PrevLine(lnum: number): number
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
enddef

def GetOrgIndent(lnum: number): number
  var ind: number = lnum
  var plnum: number = prevnonblank(lnum - 1)
  var pline: string = getline(lnum - 1)
  var pind: number = indent(plnum)
  var level: number = pind
  if pline =~ '^\s*- \['
    return level + 6
  # elseif pline =~ '^\s*- ' || pline =~ '^\s*+ ' || pline =~ '^\s*\* '
  elseif pline =~ '^\s*[+-\*] '
    return level + 2
  # TODO: Add conditional for count decimals and adjust level
  elseif pline =~ '^\s*\d[\.\)] '
    return level + 3
  elseif pline =~ '^\s*[0-9i]\{2}[\.\)] '
    return level + 4
  elseif pline =~ '^\s*\d\d\d[\.\)] '
    return level + 5
  elseif pline =~ '^\s*\a[\.)] '
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
  # else
  endif
  return level
enddef

