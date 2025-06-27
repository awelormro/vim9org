if !has('vim9script')
  finish
endif
vim9script

if !exists('g:org_backend')
  g:org_backend = 'vim9script'
endif

if g:org_backend != 'vim9script'
  finish
endif

if exists('b:org_started')
  finish
endif

b:org_started = 1
echo 'vim9script mode activated'
import autoload "v9sc/start.vim" as start
start.General_start()

