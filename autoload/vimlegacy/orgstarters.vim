" vim: set nospell:
" vim: set foldmethod=marker:

function vimlegacy#orgstarters#Vimscriptstart()
  setlocal tw=80
  setlocal foldmethod=expr
  if !exists('g:org_backend') || g:org_backend == 'vim9script'
    let g:org_backend = 'legacy'
  endif
endfunction


