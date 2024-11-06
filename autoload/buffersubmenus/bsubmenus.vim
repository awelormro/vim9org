vim9script
export def CreateBuffer(bufft : string, bufhght: string) # {{{
  var spltblw = &splitbelow
  exe 'set splitbelow'
  exe bufhght .. ':new'
enddef # }}}
