if !has('python3')
  finish
endif

if !exists('g:org_backend')
  finish
endif

if g:org_backend != 'python'
  finish
endif

if exists('b:org_started')
  finish
endif

let b:org_started = 1

py3 import startorg
py3 startorg.start_org()

setlocal foldmethod=expr
setlocal foldexpr=OrgPyFold()

function! OrgPyFold() abort
  py3 import pyfold
  let ret = py3eval('pyfold.OrgFolding()')
  return ret
endfunction

function! OrgPyIndent() abort
  py3 import indent
  return py3eval('indent.PyindentOrg()')
endfunction

setlocal indentexpr=OrgPyIndent()
