if exists('b:narrow_syntax')
  finish
endif

let b:narrow_syntax = 1

setlocal bufhidden=wipe
nnoremap <buffer> q :ReturnNarrow<CR>
inoremap <buffer> <C-q> <C-o>:ReturnNarrow<CR>
