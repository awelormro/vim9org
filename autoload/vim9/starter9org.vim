" vim: set nospell:
" vim: set foldmethod=marker:
if !has('vim9script')
  echo '9org file, not allowed'
  finish
endif
vim9script
export def Starter9org()
  setlocal foldmethod=expr
  setlocal textwidth=80
  echo "Vim9script core enabled"
enddef
