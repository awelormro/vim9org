vim9script
# vim: set foldmethod=marker: 
# Exporter Settings {{{


# Generate an export function to use with the format option as the argument,
# remember, in vim9script if you use variables as arguments of the function,
# you must declare the type of the data used, also you must declare the type
# in case you need to, similar to the things used in the command function.
export def OrgExporter(format: string) # {{{
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
enddef #  }}}
# Remember to make the customlist function with these 3 condition and variable
# formats, and export the result as a list of strings.
export def CompleteFormatPandoc(A: string, L: string, P: number): list<string> # {{{
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
enddef # }}}
export def CompleteFormatEmacs(A: string, L: string, P: number): list<string> # {{{
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
enddef #  }}}
 # {{{
# if g:org_export_engine == 'pandoc'
#   command! -buffer -nargs=* -complete=customlist,CompleteFormatPandoc OrgConvertToFormat OrgExporter(<q-args>)
# elseif g:org_export_engine == 'emacs'
# endif

# }}}
