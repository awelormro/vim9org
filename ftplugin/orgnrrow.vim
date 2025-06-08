if !has('vim9script')
  finish
endif
vim9script
# ~/Plantillas/vim9org/autoload/v9sc/nrrow.vim
import autoload "v9sc/nrrow.vim" as nrrow
command -buffer Org
nnoremap <buffer><silent> q :
