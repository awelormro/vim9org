vim9script
# vim: set fdm=marker:
# vim: set nospell:
# Description: All the functions here are made to count lines with
# determinate symbols, characteristics or similar, they are to count until a
# condition is determinate, until find a symbol or condition in line, and has
# a lock to check if there are valid to get the number of line in case of
# every kind of position
# VimFuncsToCheck: {{{ 
# getcurpos:  {{{
# Get the position of the cursor.  This is like getpos('.'), but
# includes an extra "curswant" item in the list:
#     [0, lnum, col, off, curswant] 
# }}}
# }}}
export def ListCheckCondsLine(smbol: list<any>, ln: number): number # {{{
  for sym in smbol
    if getline( ln ) =~ smbol
      return 1
    endif
  endfor
  return 0
enddef # }}}
export def ListCheckCondsStrDct(smbol: dict<any>, strng: string ): string
  var lstkys = keys( smbol )
  for sym in lstkys
    if smbol[sym] =~ strng
      return sym
    endif
  endfor
  return 'Text'
enddef
export def CountLinesUpIf(smbol: list<any>, brk: list<any>, pos: list<any>): number # {{{ 
  var i = pos[1]
  while i >= 0
    if ListCheckCondsLine(smbol, i) == 1 && ListCheckCondsLine(brk, i) == 0
      i -= 1
    else
      return i
    endif
  endwhile
  echo i
  return i
enddef # }}}
export def CountLinesDownIf(smbol: list<any>, brk: list<any>, pos: list<any>): number # {{{
  var i = pos[1]
  var nd = line( '$' )
  while i <= nd
    if ListCheckCondsLine(smbol, i) == 1 && ListCheckCondsLine(brk, i) == 0
      i += 1
    else
      return i
    endif
  endwhile
  echo i
  return i
enddef #  }}}
