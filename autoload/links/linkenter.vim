vim9script
# vim: set foldmethod=marker:
# vim: set nospell:

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
def ValidateLink(): list<any>  # {{{
  # Declare variables to use {{{
  var curr_line_pos = getcurpos() # Get cursor position, Remember, list comes in order: [0, lnum, col, off, curswant]
  var cont_line = getline(curr_line_pos[1]) # Content in Line
  var pairs_to_search = ["[[", "][", "]]"] # all parentheses needed
  var data_in_link = [] # List to export, will contain all the info, data will be if found (start, end, break)
  # }}}
  var i = curr_line_pos[2] # Start calculations in the current position for start link {{{
  while i > 1 # Search beggining of link
    if cont_line[i - 1 : i] == pairs_to_search[0] # Check current position and previous char
      add(data_in_link, i - 1)
      break
    elseif cont_line[ i : i + 1 ] == pairs_to_search[0] # Check current position and next char
      add(data_in_link, i)
      break
    endif
    i -= 1
  endwhile # }}}
  i = curr_line_pos[2]
  if len(data_in_link) > 0
    while i < strlen(cont_line) # Start calculations in the current position for end link {{{
      if cont_line[i : i + 1] == pairs_to_search[2]
        add(data_in_link, i)
        break
      endif
      i += 1
    endwhile # }}}
  endif
  var data_link = ''
  if len(data_in_link) == 2
    data_link = cont_line[ data_in_link[0] : data_in_link[1] ]
    if stridx(data_link, pairs_to_search[1]) > -1
      add( data_in_link, split(data_link[2 : -2], pairs_to_search[1]) )
    else
      add(data_in_link, [ data_link[2 : -2] ])
    endif
  endif
  # extend([ data_link ], )
  return data_in_link
enddef
# }}}
def EnterFileInLink() # {{{
enddef # }}}
def GenerateCommandInLink(data: list<any>) # {{{
  if len(data) > 2
    if data[2][0] =~ '^vim:'
      exe data[2][0][4 :]
    elseif data[2][0] =~ '^lua:'
      # echo data[2][0][3 :]
      exe 'lua ' .. data[2][0][4 :]
    elseif data[2][0] =~ '^python:'
      exe 'py3 ' .. data[2][0][5 :]
    endif
  endif
enddef # }}}
def EnterInternalLink() # {{{
enddef # }}}
export def EnterToLink() # {{{
  var link_info = ValidateLink()
  # echo link_info
  if link_info[2][0] =~ '^\a*:'
    # echo 'going to start the command'
    GenerateCommandInLink(link_info)
  endif
enddef # }}}
