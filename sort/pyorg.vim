" Check if python exist
if !has('python3')
  finish
endif

" Check if the backend variable exists 
if !exists('g:org_backend')
  finish
endif

" Check if the backend variable is python
if g:org_backend != 'python'
  finish
endif

if exists('g:org_plugs_started')
  finish
endif

let g:org_plugs_started = 1

py3 import pyorg
py3 pyorg.start()
