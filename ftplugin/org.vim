vim9script
# vim: set fdm=marker:
# " echo 1
# b:current_syntax='org'
#
# Check if syntax exists for file {{{
if !exists('b:current_syntax')
  finish
endif
b:current_syntax = 'org'
# }}}
# Import files {{{

# setlocal commentstring="/*#%s*"
setlocal tw=80
# setlocal comments=fb:*,b:#,fb:-
setlocal commentstring=#%s
setlocal comments=sO:#,m:#,e:#,b:*,b:-
import autoload "links/linkenter.vim" as lnks
import autoload "todowords/toggletodo.vim" as tdo
import autoload "todowords/orgcheckboxes.vim" as lst
import autoload "export/exporters.vim" as exprt
# import autoload "org_links.vim"
# import autoload "org_normal.vim"
# import autoload "org_tables.vim" as tbl
# import autoload "org_spreads.vim" as sprd
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
  if line == ':PROPERTIES:'
    # echo "Properties section"
    var lnum_end = search(':END:', 'n', v:lnum + 1)
    if lnum_end > lnum
      return '<3'  # Nivel de plegado inferior al de los encabezados
    endif
  endif
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
command -buffer OrgEnterLink          lnks.OrgEnterLink()
command -buffer OrgFollowNextLink     lnks.OrgSearchNextLink()
command -buffer OrgFollowPrevLink     lnks.OrgSearchPrevLink()
command -buffer OrgCheckBoxUpdate     lst.OrgCheckboxupdate() 
command -buffer OrgCheckBoxInsert     lst.OrgCheckboxinsert()
# command -buffer OrgCheckBoxUpdate     call todowords#checklists#Checkboxupdate()
# command -buffer OrgCheckBoxInsert     call todowords#checklists#CheckboxInsert()
command -buffer OrgTODOToggleRight    tdo.OrgTodoShifterRight()
command -buffer OrgTODOToggleLeft     tdo.OrgTodoShifterLeft()
command -buffer OrgTODOTogglePriorUp  tdo.OrgPrioritiesRight()
command -buffer OrgTODOTogglePriorDwn tdo.OrgPrioritiesLeft()
command -buffer OrgReloadconf         so Plantillas/vim9org/ftplugin/org.vim
command -buffer OrgFollowNextHead     lnks.OrgSearchNextHead()
command -buffer OrgFollowPrevtHead     lnks.OrgSearchPrevHead()
#  }}}
# Declare Variables in case of need {{{
if !exists("g:org_tbl_cell_to_use")
  g:org_tbl_cell_to_use = 'top'
endif
#  }}}
# Custom function tests {{{
# Declaramos una función llamada `ShowPopupWindow` que se encargará de crear la ventana
def ShowPopupWindow() # {{{

  # Define las opciones del popup
  var opts = {
         'line': 5,                  # Línea donde aparecerá la ventana
         'col': 10,                  # Columna donde aparecerá la ventana
         'minwidth': 20,             # Ancho mínimo de la ventana
         'minheight': 5,             # Alto mínimo de la ventana
         'border': []                # Borde alrededor del popup
         }

  # Contenido del popup
  var content = ['Hola, este es un popup!', 'Usando Vim9script']

  # Crea la ventana emergente usando popup_create()
  call popup_create(content, opts)
enddef # }}}
def PopupSave(arg: number) # {{{
  if arg == 1
    execute('w')
    echo "Saved file"
  endif
enddef # }}}
def PandocConvert() # {{{

enddef # }}}
def PandocExportPopup() # {{{
  var frmats = [ 'docx', 'pdf', 'tex', 'beamer', 'beamertex', 'pptx' ]
  popup_menu(frmats, {
    callback: (_, result) => {
      PopupSave(result)
    },
    filter: (id, key) => {
      # Handle shortcuts
      if key == 'd' || key == 'D'
        popup_close(id, 1)
      elseif key == 'p' || key == 'P'
        popup_close(id, 2)
      elseif key == 't' || key == 'T'
        popup_close(id, 3)
      else
        # No shortcut, pass to generic filter
        return popup_filter_menu(id, key)
      endif
      return true
    },
  })

enddef # }}}
def ShowPopupMenu() # {{{ 
  # Opciones del menú
  var content = ['Opción 1: Abrir archivo',
    'Opción 2: Guardar archivo',
    'Opción 3: Cerrar ventana',
    'Opción 4: Salir']

  # Definir las opciones del popup
  var opts = {
    'line': 5,                  # Línea donde aparecerá el menú
    'col': 15,                  # Columna donde aparecerá el menú
    'minwidth': 30,             # Ancho mínimo del popup
    'minheight': 7,             # Alto mínimo del popup
    'border': 'rounded',        # Borde redondeado alrededor del popup
    'filter': 'MenuPopupFilter' # Filtrar los eventos para la interacción
  }

  # echo 'dialog result is' result
  popup_menu(['Save', 'Cancel', 'Discard'], {
    callback: (_, result) => {
      PopupSave(result)
    },
    filter: (id, key) => {
      # Handle shortcuts
      if key == 'S' || key == 's'
        popup_close(id, 1)
      elseif key == 'C' || key == 'c'
        popup_close(id, 2)
      elseif key == 'D' || key == 'd'
        popup_close(id, 3)
      else
        # No shortcut, pass to generic filter
        return popup_filter_menu(id, key)
      endif
      return true
    },
  })
  # Crear el popup y guardar su ID
  # var popup_id = popup_create(content, opts)
enddef # }}}

#  }}}
# Testing commands {{{
command -buffer OrgTableCreate tbl.OrgInsertTable()
command -buffer OrgTableAddColumn tbl.OrgAddColumn()
command -buffer -nargs=* OrgMenuCreation org_normal.Bufmenucreate(<q-args>)
command -buffer Orgaugrps org_normal.TestExportandBypass()
#  }}}
# Mapping creations {{{
# Symbolic mapping creations with <Plug> {{{
map <buffer> <Plug>OrgTDTogRight       :OrgTODOToggleRight<CR>
map <buffer> <Plug>OrgTDTogLeft        :OrgTODOToggleLeft<CR>
map <buffer> <Plug>OrgPrTogUp          :OrgTODOTogglePriorUp<CR>
map <buffer> <Plug>OrgPrTogDw          :OrgTODOTogglePriorDwn<CR>
map <buffer> <Plug>OrgLnFolNxt         :OrgFollowNextLink<CR>
map <buffer> <Plug>OrgLnFolPre         :OrgFollowPrevLink<CR>
map <buffer> <Plug>OrgHeFolNxt         :OrgFollowNextHead<CR>:
map <buffer> <Plug>OrgHeFolPre         :OrgFollowPrevtHead<CR>
map <buffer> <Plug>OrgLnEnter          :OrgEnterLink<CR>
map <buffer> <Plug>OrgCheckBoxUpdate   :OrgCheckBoxUpdate<CR>
map <buffer> <Plug>OrgCheckBoxInsert   :OrgCheckBoxInsert<CR>
# map <buffer> <Plug>


# }}}
# Default maps for normal mode {{{
# if vim.repeat is installed, will use it
if !exists("g:org_repeat_use")
  g:org_repeat_use = 0
endif
if g:org_repeat_use == 1
  nnoremap <buffer> <S-Right>    <Plug>OrgTDTogRight<Bar>:silent!  call repeat#set("\<Plug>OrgTDTogRight")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <S-Left>     <Plug>OrgTDTogLeft<Bar>:silent!   call repeat#set("\<Plug>OrgTDTogLeft")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <Leader>pu   <Plug>OrgPrTogUp<Bar>:silent!     call repeat#set("\<Plug>OrgPrTogUp")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <Leader>pd   <Plug>OrgPrTogDw<Bar>:silent!     call repeat#set("\<Plug>OrgPrTogDw")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <Leader>oln  <Plug>OrgLnFolNxt<Bar>:silent!    call repeat#set("\<Plug>OrgLnFolNxt")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <Leader>olp  <Plug>OrgLnFolPre<Bar>:silent!    call repeat#set("\<Plug>OrgLnFolPre")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <Leader>ole  <Plug>OrgLnEnter<Bar>:silent!     call repeat#set("\<Plug>OrgLnEnter")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <leader>ohn  <Plug>OrgHeFolNxt<bar>:silent!    call repeat#set("\<Plug>OrgHeFolNxt")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <leader>ohp  <Plug>OrgHeFolPre<bar>:silent!    call repeat#set("\<Plug>OrgHeFolPre")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <leader>c<leader>i <Plug>OrgCheckBoxInsert<bar>:silent! call repeat#set("\<Plug>OrgCheckBoxInsert")<CR><bar>:echo ""<CR>
  nnoremap <buffer> <leader>c<leader>c <Plug>OrgCheckBoxUpdate<bar>:silent! call repeat#set("\<Plug>OrgCheckBoxUpdate")<CR><bar>:echo ""<CR>
else
  nnoremap <buffer> <S-Right>    <Plug>OrgTDTogRight
  nnoremap <buffer> <S-Left>     <Plug>OrgTDTogLeft
  nnoremap <buffer> <Leader>pu   <Plug>OrgPrTogUp
  nnoremap <buffer> <Leader>pd   <Plug>OrgPrTogDw
  nnoremap <buffer> <Leader>oln  <Plug>OrgLnFolNxt
  nnoremap <buffer> <Leader>olp  <Plug>OrgLnFolPre
  nnoremap <buffer> <Leader>ole  <Plug>OrgLnEnter
  nnoremap <buffer> <leader>ohn  <Plug>OrgHeFolNxt
  nnoremap <buffer> <leader>ohp  <Plug>OrgHeFolPre
  nnoremap <buffer> <leader>c<leader>i <Plug>OrgCheckBoxInsert
  nnoremap <buffer> <leader>c<leader>c <Plug>OrgCheckBoxUpdate
endif
#  }}}
nnoremap <buffer> <leader>c<leader>i <Plug>OrgCheckBoxInsert
#  }}}
