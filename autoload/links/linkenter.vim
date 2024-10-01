vim9script
# vim: set foldmethod=marker:

export def OrgSearchNextHead() # {{{
  search('^\* ')
  echo ""
enddef # }}}
export def OrgSearchPrevHead() # {{{
  search('^\* ', 'b')
  echo ""
enddef # }}}
export def OrgSearchNextLink() # {{{
  search('\[\[')
  echo ""
enddef #  }}}
export def OrgSearchPrevLink() # {{{
  search('\[\[', 'b')
  echo ""
enddef # }}}
export def OrgEnterLink() # {{{
  # Needed: {{{
  # - Obtain the [[link]] or [[link][Description]]
  # - Obtain the path
  # - Cursor must be inside the link structure
  # obtain the first sqare brackets information
  # - Delete the parentheses
  # - delete all the strings after the square bracket on a variable and add it
  #   inside a variable
  # - if is .org org a plain text file, open it.
  # - If is a pdf, docx, odt or image format, execute xdg-open or start in
  #   case of being windows
  # }}}
  # Variable Declarations {{{
  var full_path_file = expand('%:p:h')
  # echo full_path_file
  var cursor_line = line('.')
  var cursor_column = col('.')
  var current_line_content = getline('.')
  var i = cursor_column - 1
  var cursor_column_sp = split(current_line_content, '\zs')
  # echo cursor_line
  # echo cursor_column
  # echo cursor_column_sp
  var link_name_start: string
  var link_name_start_col: number
  var link_name_splitted: list<string>
  var link_name_chars: list<string>
  # }}}
  if current_line_content =~ '\[\['
    # While loop to verify in the current position if there is a link{{{
    while i > -1
      if i < 2
        if cursor_column_sp[0] == '[' && cursor_column_sp[1] == '[' 
          # echo 'Begin of line has a link'
          # link_name_start = cursor_column_sp[2]
          i = 2
          break
        endif
      elseif (cursor_column_sp[i] == ']' && cursor_column_sp[i - 1] == ']') ||
          (cursor_column_sp[i] == ']' && cursor_column_sp[i + 1] == ']')
        # echo 'Not a link start'
        i -= 1000
        break
      elseif cursor_column_sp[i] == '[' && cursor_column_sp[i + 1] == '[' 
        # echo 'Link start detected'
        i += 2
        break
      elseif cursor_column_sp[i] == '[' && cursor_column_sp[i - 1] == '[' 
        # echo 'Link start detected'
        i += 1
        break
      elseif i == -1
        i = -1000
      else
        i -= 1
      endif
    endwhile
    # }}}
    if i > -1
      while i < len(cursor_column_sp)
        if cursor_column_sp[i] == ']'
          break
        endif
        link_name_start = link_name_start .. cursor_column_sp[i]
        i += 1
      endwhile
    endif
    # echo link_name_start
    link_name_splitted = split(link_name_start, '\zs')
    if link_name_splitted[0] == "/"
      # echo "Has an absolute path"
      execute ':silent! e ' .. link_name_start
    elseif link_name_start =~ '.\v\..'
      # echo 'Line does have extension'
        link_name_splitted = split(link_name_start, '\v\.')
        echo link_name_splitted
        if index(g:org_xdg_external_extensions, link_name_splitted[1]) == -1
          execute ':silent! e ' .. full_path_file .. "/" .. link_name_start
        endif
    else
      # echo 'Line does not have an extension'
          execute ':silent! e ' .. full_path_file .. "/" .. link_name_start .. '.org'
    endif
  else
    echo 'Line does not contain links'
  endif
enddef # }}}

