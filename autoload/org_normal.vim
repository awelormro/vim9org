vim9script
# vim: set fdm=marker:
# First Function creation {{{
export def CallFunction()
  echo 1
enddef
# }}}
# Checkbox utilities {{{
# Toggle checkbox {{{
export def Checkboxupdate()
  # Remember [0,row,column,0]
  var curprev = getpos('.')
  # curprev = Cursor previous, getting the whole settings using getpos
  # function
  var lin = curprev[1]
  var k = lin
  while k > 0 
    # Check if lines has the checkbox uncommented section
    if getline(k) =~ '- \[ \] '
      cursor(k, 1)
      execute 's/\[ \]/\[X\]/'
      # echo 'toggled to commented'
      break
    # Check if line has the checkbox commented section
    elseif getline(k) =~ '- \[X\] '
      cursor(k, 1)
      execute 's/\[X\]/\[ \]/'
      # echo 'toggled to uncommented'
      break
    # Check if previous line has only spaces from start to end of line
    elseif getline(k) =~ '^\s*$'
      break
    # Check if previous line is empty
    elseif empty(getline(k))
      break
    else
      k -= 1
    endif
  endwhile
  # Go back to cursor position
  cursor(curprev[1], curprev[2])
  # echo 'not list found'
  # [X] Cosas pendejas
enddef
# }}}
# Insert Checkbox {{{
export def ChecboxInsert()
  append(line('.'), '- [ ]  ')
  cursor(line('.') + 1, 7)
  startinsert
  execute "normal \<Right>"
  normal l
enddef
# }}}
# }}}
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

# }}}
# Exporter Settings {{{

# Generate a variable to select the export engine

# Generate an export function to use with the format option as the argument,
# remember, in vim9script if you use variables as arguments of the function,
# you must declare the type of the data used, also you must declare the type
# in case you need to, similar to the things used in the command function.
export def OrgExporter(format: string)
  if g:org_export_engine == 'pandoc'
    if format == 'beamer'
      var finame = expand('%:t:r')
      execute '!pandoc % -t beamer ' .. g:org_export_pandoc_args .. ' -o' .. finame .. '.pdf'
    elseif format == 'beamertex'
      var finame = expand('%:t:r')
      execute '!pandoc % -t beamer ' .. g:org_export_pandoc_args .. '-o' .. finame .. '.tex'
    elseif format == 'powerpoint'
      var finame = expand('%:t:r')
      execute '!pandoc % ' .. g:org_export_pandoc_args .. ' -o ' .. finame .. '.pptx'
    elseif format == 'markdown'
      var finame = expand('%:t:r')
      execute '!pandoc % -t markdown ' .. g:org_export_pandoc_args .. ' -o ' .. finame .. '.md'
    else
      var finame = expand('%:t:r')
      execute '!pandoc %  ' .. g:org_export_pandoc_args .. ' -t ' .. format .. ' -o' .. finame .. '.' .. format
    endif
  elseif g:org_export_engine == 'emacs'
    if format == 'tex'
      execute '!emacs % --batch -f org-latex-export-to-latex --kill'
    elseif format == 'html'
      execute '!emacs % --batch -f org-html-export-to-html --kill'
    elseif format == 'odt'
      execute '!emacs % --batch -f org-odt-export-to-odt --kill'
    elseif format == 'markdown'
      execute '!emacs % --batch -f org-md-export-to-markdown --kill'
    elseif format == 'beamer'
      execute '!emacs % --batch -f org-beamer-export-to-pdf --kill'
    elseif format == 'beamertex'
      execute '!emacs % --batch -f org-beamer-export-to-latex --kill'
    elseif format == 'pdf'
      execute '!emacs % --batch -f org-latex-export-to-pdf --kill'
    endif
  else
    echoerr 'Not configured'
  endif
enddef

# Remember to make the customlist function with these 3 condition and variable
# formats, and export the result as a list of strings.
export def CompleteFormatPandoc(A: string, L: string, P: number): list<string>
  # Create a list
  var formats = ["docx", "html", "markdown", "tex", "odt", 'powerpoint', 'rtf', 'revealjs', 'beamer', 'beamertex']
  # Append to the first variable a ^ symbol to indicate the start of string in
  # list, used to make a filter and create it GLOBAL to get access from
  # command line
  g:orgCommandExporterAux = "^" .. A
  # Create a variable with the filter and the condition of the entry to make
  # it searchable using tab
  var filtered = filter(formats, 'v:val =~ g:orgCommandExporterAux')
  # Export the filtered results to being used in the command function
  return filtered
enddef

export def CompleteFormatEmacs(A: string, L: string, P: number): list<string>
  # Create a list
  var formats = ["html", "markdown", "tex", "odt", 'beamer', 'beamertex']
  # Append to the first variable a ^ symbol to indicate the start of string in
  # list, used to make a filter and create it GLOBAL to get access from
  # command line
  g:orgCommandExporterAux = "^" .. A
  # Create a variable with the filter and the condition of the entry to make
  # it searchable using tab
  var filtered = filter(formats, 'v:val =~ g:orgCommandExporterAux')
  # Export the filtered results to being used in the command function
  return filtered
enddef


# }}}
# Test implicit functions {{{
def Sum2nums(a: number, b: number): number
  echo a + b
  return a + b
enddef
export def SumFunction()
  echo 'The function that call another function'
  var var1 = str2nr(input('Number 1: '))
  echo "\n"
  echo var1
  var var2 = str2nr(input('Number 2: '))
  echo "\n"
  echo var2
  Sum2nums(var1, var2)
enddef
#  }}}
# Commands creation {{{
# command -buffer OrgEcho CallFunction()
# command -buffer OrgCheckBoxToggle Checkboxupdate()
# command -buffer OrgCheckBoxInsert ChecboxInsert()
# }}}
# Create popup menus and notifications for the user experience {{{

def OrgOptionselected(id: number, result: number)
  echo a:result
  echo a:id
enddef

export def OrgmenuPopup()
  popup_menu(['mamada', 'pendejada'], {callback: OrgOptionselected})
enddef

#  }}}
# Attempt to create a split below or above and write one {{{
def DefOrgMenuContext(menutype: string): list<string>
  if menutype == 'General'
    return ['Save File   [ ]',
            'Export File [ ]',
            'Create Link [ ]'
    ]
  else
    return ['Not a menu setting, press q to exit']
  endif

enddef

def OrgEnableTableMode()
  augroup org_tables
    autocmd InsertLeave *.org 
  augroup END
enddef



export def Bufmenucreate(orgmenu: string)
  :10new 
  setlocal bufhidden=wipe buftype=nofile filetype=dash nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber
  append(line('$'), 'I Use Arch BTW')
  execute ':%center'
  var orgmenu_put = DefOrgMenuContext(orgmenu)
  for element in orgmenu_put
    append(line('$'), element)
  endfor
  setlocal nomodifiable nomodified
  # cursorpos()
  nnoremap <buffer> h j
  nnoremap <buffer> l k
  nnoremap <buffer> q :q<CR>
enddef
#  }}}
# Autocommands toggled to use in case to activate several settings {{{

def ToggleTestAutoGroup()
    if !exists('g:TestAutoGroupMarker')
        g:TestAutoGroupMarker = 1
    endif

    # Enable if the group was previously disabled
    if (g:TestAutoGroupMarker == 1)
        g:TestAutoGroupMarker = 0
        # actual augroup
        augroup TestAutoGroup
            autocmd! BufEnter   * echom "BufEnter " .. bufnr("%")
            autocmd! BufLeave   * echom "BufLeave " .. bufnr("%")
            autocmd! TabEnter   * echom "TabEnter " .. tabpagenr()
            autocmd! TabLeave   * echom "TabLeave " .. tabpagenr()
        augroup END
    else    # Clear the group if it was previously enabled
        g:TestAutoGroupMarker = 1
        # resetting the augroup
        augroup TestAutoGroup
            autocmd!
        augroup END
    endif
enddef

export def TestExportandBypass()
  ToggleTestAutoGroup()
enddef
#  }}}
