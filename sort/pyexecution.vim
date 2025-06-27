py3 import checklists as cls
command -buffer OrgPyChecklist :py3 cls.checklist_toggle_status()

py3 import pyfold
function! OrgPyFold() abort
  return py3eval('pyfold.OrgFolding()')
endfunction

setlocal foldmethod=expr
setlocal foldexpr=OrgPyFold()
