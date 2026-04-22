if !has('nvim') || !has('lua')
    finish
endif

if !exists('g:org_backend')
  if has('nvim')
    let g:org_backend = 'lua'
  endif
endif

if g:org_backend != 'lua'
  finish
endif

if exists('b:org_started')
  finish
endif

let b:org_started = 1

echo 'lua core started'
