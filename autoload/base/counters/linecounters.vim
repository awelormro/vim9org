vim9script

# getcurpos   [0, lnum, col, off, curswant] ~
export def CountLinesUpIf(smbol: list<any>, brk: list<any>, pos: list<any>): number
  var i = pos[1]
  while i <= 0
    for sym in smbol
      if getline( i ) =~ sym
        i -= 1
        break
      endif
    endfor
  endwhile
  echo i
  return i
enddef
export def CountLinesDownNt(smbol: list<any>, brk: list<any>): number
  var i = 0
  return i
enddef
export def CountLinesUpTil(smbol: list<any>, brk: list<any>): number
  var i = 0
  return i
enddef
export def CountLinesDownTil(smbol: list<any>, brk: list<any>): number
  var i = 0
  return i
enddef
