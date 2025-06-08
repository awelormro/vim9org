if has('vim9script')
  finish
endif

function! legacy#searchers#Searchlinkprev()
  let cursor_col = col('.')
  let cursor_row = line('.')
  call search('\[\[', 'b')
  call cursor(line('.'), col('.') + 2)
  if cursor_col == col('.') && cursor_row == line('.')
    call cursor(line('.'), col('.') - 2)
    call search('\[\[', 'b')
    call cursor(line('.'), col('.') + 2)
  endif
endfunction

function! legacy#searchers#Searchlinknext()
  call search('\[\[')
  call cursor(line('.'), col('.') + 2)
endfunction

function! legacy#searchers#Searchheadprev()
  call search('^\*', 'b')
endfunction

function! legacy#searchers#Searchheadprev()
  call search('^\*', 'b')
endfunction
