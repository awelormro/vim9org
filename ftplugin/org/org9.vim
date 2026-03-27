if !has('vim9script')
  finish
endif
vim9script

import autoload 'v9sc/todo.vim' as todo

command! -buffer OrgTODOForward todo.Todo_Search(true)
command! -buffer OrgTODOBackward todo.Todo_Search(false)
command! -buffer OrgCheckboxToggle todo.Todo_checkbox()
command! -buffer OrgTODOPriorUp todo.Todo_Prioritie_Search(true)
