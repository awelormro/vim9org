if !has('vim9script') " {{{
  finish
endif " }}}

vim9script

export def Timestamp_toggle() # {{{
  var verifier: bool = Timestamp_verify_pos()
  if !verifier
    return
  endif
enddef # }}}

def Timestamp_verify_pos(): bool # {{{
  var cusor_por = getpos('.')
  var splitted_line = split(getline('.'), '\sz')
  var splitted_line_reversed = reverse(split(getline('.'), '\sz'))
enddef # }}}

export def Timestamp_insert() # {{{
enddef # }}}
