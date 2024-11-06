vim9script
# vim: set foldmethod=marker:

setlocal bufhidden=wipe buftype=nofile nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber
import autoload "submenus/submenus.vim" as sbmnu
command -buffer MenuMoveLeft sbmnu.MoveLeft()
command -buffer MenuMoveRight sbmnu.MoveRight()
nnoremap <buffer> h :MenuMoveLeft<CR>
nnoremap <buffer> l :MenuMoveRight<CR>
nnoremap <buffer> <Left> :MenuMoveLeft<CR>
nnoremap <buffer> <Right> :MenuMoveRight<CR>
nnoremap <buffer> <CR> :MenuConfirm<CR>
nnoremap <buffer> q :bd!<CR>
sbmnu.MenuTags()
