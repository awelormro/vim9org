vim9script

# setlocal commentstring=#\ %s
# " Fold method plugin {{{1
# function! s:NotCodeBlock(lnum) abort
#   return synIDattr(synID(a:lnum, 1, 1), 'name') !=# 'OrgCodeBlock'
# endfunction
# function! OrgFold() abort
#   let line = getline(v:lnum)
# 
#   if line =~# '^\*\+ ' && s:NotCodeBlock(v:lnum)
#     return ">" . match(line, ' ')
#   endif
# 
#   let nextline = getline(v:lnum + 1)
#   if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
#     return ">1"
#   endif
# 
#   if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1)
#     return ">2"
#   endif
# 
#   return "="
# endfunction
# 
# setlocal tw=75
# " setlocal foldexpr=OrgFold()
# " setlocal foldmethod=expr
# " vim9cmd 'import orgnormal.vim'
# }}}
# vim: set fdm=marker:
# First Function creation {{{
def CallFunction()
  echo 1
enddef
# }}}
# Checkbox utilities {{{
# Toggle checkbox {{{
def Checkboxupdate()
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
def ChecboxInsert()
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

setlocal foldmethod=expr
setlocal foldexpr=OrgFold9s(v:lnum)

# }}}
# Exporter Settings {{{

# Generate a variable to select the export engine
if !exists('g:org_export_engine')
  g:org_export_engine = 'pandoc'
endif

if !exists('g:org_export_pandoc_args')
  g:org_export_pandoc_args = ' '
endif

# Generate an export function to use with the format option as the argument,
# remember, in vim9script if you use variables as arguments of the function,
# you must declare the type of the data used, also you must declare the type
# in case you need to, similar to the things used in the command function.
def OrgExporter(format: string)
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
def CompleteFormatPandoc(A: string, L: string, P: number): list<string>
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

def CompleteFormatEmacs(A: string, L: string, P: number): list<string>
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

if g:org_export_engine == 'pandoc'
  command! -buffer -nargs=* -complete=customlist,CompleteFormatPandoc OrgConvertToFormat OrgExporter(<q-args>)
elseif g:org_export_engine == 'emacs'
endif

# }}}
# Commands creation {{{
command -buffer OrgEcho CallFunction()
command -buffer OrgCheckBoxToggle Checkboxupdate()
command -buffer OrgCheckBoxInsert ChecboxInsert()
command -buffer OrgEnterLink g:OrgEnterLink()
# }}}
