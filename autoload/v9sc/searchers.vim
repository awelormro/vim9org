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
#  finders in vim9script {{{

export def Find_next_header()
  search('^\*')
enddef

export def Find_prev_header()
  search('^\*', 'b')
enddef

export def Find_next_link()
  search('\[\[')
  cursor(line('.'), col('.') + 2)
enddef

export def Find_prev_link()
  var cursor_col = col('.')
  var cursor_row = line('.')
  search('\[\[', 'b')
  cursor(line('.'), col('.') + 2)
  if cursor_col == col('.') && cursor_row == line('.')
    cursor(line('.'), col('.') - 2)
    search('\[\[', 'b')
    cursor(line('.'), col('.') + 2)
  endif
enddef

export def Find_next_cite()
  search('\[cite')
  cursor(line('.'), col('.') + 1)
enddef

export def Find_prev_cite()
  var cursor_col = col('.')
  var cursor_row = line('.')
  search('\[cite', 'b')
  cursor(line('.'), col('.') + 1)
  if cursor_col == col('.') && cursor_row == line('.')
    cursor(line('.'), col('.') - 1)
    search('\[\[', 'b')
    cursor(line('.'), col('.') + 1)
  endif
enddef
# }}}
