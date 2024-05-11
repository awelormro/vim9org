vim9script
# vim: set fdm=marker:
# " echo 1
# let b:current_syntax='org'
#
# if !exists('b:current_syntax')
#   finish
# endif
# b:current_syntax = 'org'
# Import files {{{

setlocal commentstring="/*#%s*"

setlocal comments=fb:*,b:#,fb:-
import autoload "org_links.vim"
import autoload "org_normal.vim"
import autoload "org_todos.vim"
import autoload "org_tables.vim" as tbl
import autoload "org_spreads.vim" as sprd
#  }}}
# Importer a function to add an example {{{
def ImportFunctionFromOrgAl()
  org_normal.SumFunction()
enddef
#  }}}
# Vim9script fold function {{{
def OrgFold9s(lnum: number): string
  # echo 1
  var Ntcodeblock = (x) => synIDattr(synID(x, 1, 1), 'name') !=# 'OrgCodeBlock'
  var line = getline(v:lnum)
  if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
    return ">" .. match(line, ' ')
  endif
  var nextline = getline(v:lnum + 1)
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
    return ">1"
  endif 

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
    return ">2"
  endif

  return "="
enddef

setlocal foldmethod=expr
setlocal foldexpr=OrgFold9s(v:lnum)
if !exists('g:org_export_engine')
  g:org_export_engine = 'pandoc'
endif
if !exists('g:org_export_pandoc_args')
  g:org_export_pandoc_args = ' '
endif


if g:org_export_engine == 'pandoc'
  command! -buffer -nargs=* -complete=customlist,org_normal.CompleteFormatPandoc OrgConvertToFormat org_normal.OrgExporter(<q-args>)
elseif g:org_export_engine == 'emacs'
endif
# }}}
# Command declarations {{{

command -buffer OrgCreateTable        tbl.OrgInsertTable()
command -buffer OrgEnterLink          org_links.OrgEnterLinkal()
command -buffer OrgFollowNextLink     org_links.OrgFindLinkNext()
command -buffer OrgFollowPrevLink     org_links.OrgFindLinkPrev()
command -buffer OrgCheckBoxUpdate     org_normal.Checkboxupdate()
command -buffer OrgCheckBoxInsert     org_normal.CheckboxInsert()
command -buffer OrgTODOToggleRight    org_todos.OrgTodoShifterRight()
command -buffer OrgTODOToggleLeft     org_todos.OrgTodoShifterLeft()
command -buffer OrgTODOTogglePriorUp  org_todos.OrgPrioritiesRight()
command -buffer OrgTODOTogglePriorDwn org_todos.OrgPrioritiesLeft()
#  }}}
# Declare Variables in case of need {{{
if !exists("g:org_tbl_cell_to_use")
  g:org_tbl_cell_to_use = 'top'
endif
#  }}}
# Custom function tests {{{
def Orgmenupopup()
  org_normal.OrgmenuPopup() 
enddef

# def OrgAddCol()
#   org_tables.OrgNewcol()
# enddef

def Orgaddcol()
  # org_tables.OrgAddRow()
  tbl.OrgAlignCells()
enddef

def OrgNewRow()
  tbl.OrgAddRowSeparator()
enddef

def OrgNewHeader()
  tbl.OrgAddRowHeader()
enddef


def OrgSpreads()
  sprd.OrgObtainSpreadData()
enddef

#  }}}
# Testing commands {{{
command -buffer OrgTableCreate tbl.OrgInsertTable()
command -buffer OrgTableAddColumn tbl.OrgAddColumn()
command -buffer -nargs=* OrgMenuCreation org_normal.Bufmenucreate(<q-args>)
command -buffer Orgaugrps org_normal.TestExportandBypass()
#  }}}
# Mapping creations {{{
nnoremap <buffer> <S-Right> :OrgTODOToggleRight<CR>
nnoremap <buffer> <S-Left> :OrgTODOToggleLeft<CR>
nnoremap <buffer> <Leader>pu :OrgTODOTogglePriorUp<CR>
nnoremap <buffer> <Leader>pd :OrgTODOTogglePriorDwn<CR>
#  }}}
