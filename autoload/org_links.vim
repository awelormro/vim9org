vim9script
# vim: set fdm=marker:
# vim: set nospell:
g:org_xdg_external_extensions = ['png', 'pdf', 'odt', 'docx', 'jpg', 'jpeg']
# Find link in string or in buffer {{{
export def OrgFindLinkPrev()
  # Logic in this script {{{
  # - Find in line previous to cursor position that has a link expression
  # - If there is a link, stops search
  # - If not, must search for a cursor in previous line until the end and if
  #   there is not a link, go back to the cursor position.
  # }}}
  # Get main variables {{{
  # Get the current line
  # [0, lnum, col, off, curswant] ~
  var cur_line = getline('.')
  var cur_pos = getcurpos()
  echo cur_pos
  var line_number = line('.')
  var n = cur_pos[1]
  var nlc = cur_line
  # }}}
  # While loop to find the line with titles {{{
#  while n > 0
#    nlc = getline(n)
#    if nlc =~ '\[\['
#      echo 'Line ' .. string(n) .. ' has a link'
#      break
#    else
#      n -= 1
#    endif
#  endwhile
#  # }}}
  execute ':?\[\['
  normal 2l
#  var nlcs = split(nlc, '\[\[')
#  if n == cur_pos[1]
#    if cur_pos[2] > 1
#      echo 'Expression is not in the first ocurrence'
#    else
#      echo 'Expression is in the first ocurrence'
#    endif
#    echo nlcs
#  endif
enddef
export def OrgFindLinkNext()
  execute ':/\[\['
  normal 2l
enddef

# }}} [[liga]]
# Enter to a link in current cursor position {{{
export def OrgEnterLinkal()
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
  echo full_path_file
  var cursor_line = line('.')
  var cursor_column = col('.')
  var current_line_content = getline('.')
  var i = cursor_column - 1
  var cursor_column_sp = split(current_line_content, '\zs')
  echo cursor_line
  echo cursor_column
  echo cursor_column_sp
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
    echo link_name_start
    link_name_splitted = split(link_name_start, '\zs')
    if link_name_splitted[0] == "/"
      echo "Has an absolute path"
      execute 'e ' .. link_name_start
    elseif link_name_start =~ '.\v\..'
      # echo 'Line does have extension'
        link_name_splitted = split(link_name_start, '\v\.')
        echo link_name_splitted
        if index(g:org_xdg_external_extensions, link_name_splitted[1]) == -1
          execute 'e ' .. full_path_file .. "/" .. link_name_start
        endif
    else
      # echo 'Line does not have an extension'
          execute 'e ' .. full_path_file .. "/" .. link_name_start .. '.org'
    endif
  else
    echo 'Line does not contain links'
  endif
enddef

# }}}
# command -buffer OrgEnterLinkal OrgEnterLinkal()
# Sections commented {{{

    # if i + 1 == 1
    #   if (cursor_column_sp[0] == '[' && cursor_column_sp[1] == '[') 
    #     echo 'Begin of line has a link'
    #     link_name_start = cursor_column_sp[2]
    #     link_name_start_col = 2
    #   endif
    # elseif i + 1 == 2
    #   if cursor_column_sp[0] == '[' && cursor_column_sp[1] == '['
    #     echo 'Begin of line has a link'
    #     link_name_start = cursor_column_sp[2]
    #     link_name_start_col = 2
#  }}}
