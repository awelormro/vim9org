if g:org_backend != 'vim9script'
  finish
endif
vim9script

def Search_previous_header():
  search('\^\*', 'b')
enddef

def Search_next_header():
  search('\^\*')
enddef
