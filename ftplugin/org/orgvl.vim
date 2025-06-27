" any compatibility to nvim or previous version
if !has('python3') && !has('lua') && !has('vim9script')
  if !exists('g:org_backend')
    let g:org_backend = 'legacy'
  endif
endif

" 
if exists('g:org_loaded')
  finish
endif

if g:org_backend != 'legacy'
  finish
endif

let g:org_loaded = 1

echo 'Legacy mode activated'
