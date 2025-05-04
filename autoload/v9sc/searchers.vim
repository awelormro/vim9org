" vim: set fdm=marker:
if g:org_backend != 'vim9script'
  " finders in legacy vimscript {{{
  function! v9sc#searchers#find_next_header_legacy()
    call search('^\*')
  endfunction
  function! v9sc#searchers#find_prev_header_legacy()
    call search('^\*', 'b')
  endfunction
  " }}}
  finish
endif
vim9script
# finders in vim9script {{{

export def Find_next_header()
  search('^\*')
enddef

export def Find_prev_header()
  search('^\*', 'b')
enddef

export def Find_next_link()
  search('\[\[')
enddef

export def Find_prev_link()
  search('\[\[', 'b')
enddef

export def Find_next_cite()
  search('\[cite')
enddef

export def Find_prev_cite()
  search('\[cite', 'b')
enddef
# }}}
