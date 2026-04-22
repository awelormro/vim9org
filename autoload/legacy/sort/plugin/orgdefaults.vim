if !exists('g:org_backend') && !has('nvim') && v:version > 900
  let g:org_backend = 'vim9script'
elseif !exists('g:org_backend') && has('nvim')
  let g:org_backend = 'lua'
elseif !exists('g:org_backend')
  let g:org_backend = 'legacy'
endif

if !exists('g:org_fenced_languages')
  let g:org_fenced_languages = ['python', 'lua']
endif
