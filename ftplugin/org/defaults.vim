" vim: set nospell:
" vim: set foldmethod=marker:
" Selectors previously to vim9script {{{
setlocal indentexpr=indenting#OrgIndenter()
setlocal tw=80
setlocal foldmethod=expr
setlocal foldexpr=OrgFolding()
if g:org_backend == 'legacy'
  command! -buffer OrgPrevLink call vimlegacy#links#linkmains#golinkdown()
  command! -buffer OrgNextLink call vimlegacy#links#linkmains#golinkup()
endif
" }}}
