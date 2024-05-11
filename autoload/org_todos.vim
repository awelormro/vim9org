" vim: set fdm=marker:
vim9script

# Generate orgmode todo priorities style and lists {{{

if !exists('g:org_todo_priorities_style')
  g:org_todo_priorities_style = 'alphabetical'
endif

if g:org_todo_priorities_style == 'alphabetical'
  g:org_todo_priorities_list = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 
    'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ]
elseif g:org_todo_priorities_style == 'numerical'
  g:org_todo_priorities_list = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
endif
#  }}}
# Todo shifter for Todo Keywords {{{
# TODO: Currently is showing, and has the issue that only works with two
# spaces, need to make it work with only one space after the asterisks

# Function to shift todo word to the next one {{{

export def OrgTodoShifterRight()
  # Objectives of present function {{{
  # What I want to make:
  # - Select The current line
  # - If is a title, check if its first word is a title
  # - In case not, save cursor position and go upwards until the line is a
  #   title
  # - When the line is a title, it checks if the very first word is a todo
  #   keyword
  # - Copy the current line and after that, replaces the todo keyword with the
  #   previous or next todo keyword and insert it 
  # }}}
  # Get main variables {{{
  # Get the current line
  var cur_line = getline('.')
  var line_number = line('.')
  var n = line_number
  var nlc = cur_line
  # }}}
  # While loop to find the line with titles {{{
  while n > 0
    nlc = getline(n)
    if nlc =~ '^\*'
      # echo 'Line ' .. string(n) .. ' is a title'
      break
    else
      n -= 1
    endif
  endwhile
  # }}}
  # Variables to verify line {{{
  # Check Line with title and split it
  var nlcs = split(copy(nlc), ' ')
  # echo nlcs
  var i = 0
  var indn = index(g:org_todo_keywords, nlcs[1])
  # echo indn
  var newst: string
  var nlcss = split(copy(nlc), '\* ')
  var nllen = len(nlcss)
  # echo nlcss
  # }}}
  # Check conditions of line {{{

  if indn == -1
    if nllen == 1
      newst = '* ' .. g:org_todo_keywords[0] .. ' ' .. nlcss[0]
      # echo newst
    else
      newst = nlcss[0] .. '* ' .. g:org_todo_keywords[0] .. ' ' .. nlcss[1]
      # echo newst
    endif
  elseif (indn + 1) == len(g:org_todo_keywords)
    # echo 'Hide String for todo kw'
    newst = substitute(nlc, g:org_todo_keywords[-1] .. ' ', '', '')
    # echo newst
  else
    newst = substitute(nlc, g:org_todo_keywords[indn], g:org_todo_keywords[indn + 1], '')
    # echo newst
  endif
  # }}}
  # Inserts new line {{{
  append(n, newst)
  # }}}
  # Deletes the line {{{
  deletebufline('%', n)
  echo ''
  # }}}
enddef


#  }}}
# Function to go to previous todo word {{{

export def OrgTodoShifterLeft()
  # Objectives of present function {{{
  # What I want to make:
  # - Select The current line
  # - If is a title, check if its first word is a title
  # - In case not, save cursor position and go upwards until the line is a
  #   title
  # - When the line is a title, it checks if the very first word is a todo
  #   keyword
  # - Copy the current line and after that, replaces the todo keyword with the
  #   previous or next todo keyword and insert it 
  # }}}
  # Get main variables {{{

  # Get the current line
  var cur_line = getline('.')
  var line_number = line('.')
  var n = line_number
  var nlc = cur_line
  # }}}
  # While loop to find the line with titles {{{
  while n > 0
    nlc = getline(n)
    if nlc =~ '^\*'
      # echo 'Line ' .. string(n) .. ' is a title'
      break
    else
      n -= 1
    endif
  endwhile
  # }}}
  # Variables to verify line {{{
  
  # Check Line with title and split it
  var nlcs = split(copy(nlc), ' ')
  # echo nlcs
  var i = 0
  var indn = index(g:org_todo_keywords, nlcs[1])
  # echo indn
  var newst: string
  var nlcss = split(copy(nlc), '\* ')
  var nllen = len(nlcss)
  # }}}
  # Check Conditions of line {{{

  if indn == -1
    if nllen == 1
      newst = '* ' .. g:org_todo_keywords[-1] .. ' ' .. nlcss[0]
      # echo newst
    else
      newst = nlcss[0] .. '* ' .. g:org_todo_keywords[-1] .. ' ' .. nlcss[1]
      # echo newst
    endif
  elseif (indn - 1) == -1
    # echo 'Hide String for todo kw'
    newst = substitute(nlc, g:org_todo_keywords[0] .. ' ', '', '')
    # echo newst
  else
    newst = substitute(nlc, g:org_todo_keywords[indn], g:org_todo_keywords[indn - 1], '')
    # echo newst
  endif
  # }}}
  # Inserts new line {{{
  append(n, newst)
  # }}}
  # Deletes the previous line {{{
  deletebufline('%', n)
  echo ''
  # }}}
enddef

#  }}}
#  }}}
# TODO: Check spacing if the line adds priorities
# Todo priorities list {{{
export def OrgPrioritiesRight()
  # Main function objective {{{
  # - Check if The first word in title is a todo word.
  # - Check if the second spaced string is a square bracket with a 
  #   # and a letter of number, depending on the hierarchy added.
  # - Valid inputs:
  #   * TODO [#A] Get work done
  #   * DOING [#B] Get work done
  #   * DONE [#B] Get work done
  #   There can be as many asterisks as you need in the starting line, it only
  #   will change the hierarchy on the lines with todo words belonged to them,
  #   if there is not a todo keyword it will do nothing
  # }}}
  # Get main variables {{{

  # Get the current line
  var cur_line = getline('.')
  var line_number = line('.')
  var n = line_number
  var nlc = cur_line
  # }}}
  # While loop to find the line with titles {{{
  while n > 0
    nlc = getline(n)
    if nlc =~ '^\*'
      # echo 'Line ' .. string(n) .. ' is a title'
      break
    else
      n -= 1
    endif
  endwhile
  # }}}
  # Split line and check if the following word is a todo word {{{
  # Variable creation for the checking {{{

  var nlcs = split(nlc, ' ')
  var auxmenu: string
  var tdpval: string
  var tdpival: number
  var newst: string
  var tdval = index(g:org_todo_keywords, nlcs[1])
  # }}}
  if tdval >= 0
    # Check if it has a todo todo priorities section {{{
    if nlcs[2] =~ '\[\#.*\]'
      # echo 'Is a todo priorities title'
      # Trim argument to just take the letter and can verify {{{
      tdpval = trim(trim(nlcs[2], '\[\#'), '\]', 2)
      # Take index value
      tdpival = index(g:org_todo_priorities_list, tdpval)
      if tdpival == -1
        # echo 'Not a todo list element for the kind'
        newst = substitute(nlc, '\[\#.*\]', 
          '\[\#' .. g:org_todo_priorities_list[0] .. '\]', '')
        # echo newst
        
      elseif (tdpival + 1) == len(g:org_todo_priorities_list)
        # echo 'This is the last element'
        newst = substitute(nlc, '\[\#.*\] ', '', '')
        # echo newst
      else
        # echo 'Element belongs to the list'
        newst = substitute(nlc, '\[\#.*\]', 
          '\[\#' .. g:org_todo_priorities_list[tdpival + 1] .. '\]', '')
        # echo newst
      endif
      # }}}
    else
      # echo 'Is a todo title without priorities'
      newst = substitute(nlc, 
        '\* ' .. g:org_todo_keywords[tdval], 
        '\* ' .. g:org_todo_keywords[tdval] .. ' \[\#'
        .. g:org_todo_priorities_list[0] .. '\]', '')
      # echo newst
    endif
    # }}}
  else
    # echo 'is not a todo title'
      newst = substitute(nlc, 
        '\* ', 
        '\* ' .. g:org_todo_keywords[0] .. ' \[\#' 
        .. g:org_todo_priorities_list[0] .. '\]', '')
      # echo newst
  endif
  # }}}
  # Inserts new line {{{
  append(n, newst)
  # }}}
  # Deletes the previous line {{{
  deletebufline('%', n)
  echo ''
  # }}}
enddef


export def OrgPrioritiesLeft()
  # Main function objective {{{
  # - Check if The first word in title is a todo word.
  # - Check if the second spaced string is a square bracket with a 
  #   # and a letter of number, depending on the hierarchy added.
  # - Valid inputs:
  #   * TODO [#A] Get work done
  #   * DOING [#B] Get work done
  #   * DONE [#B] Get work done
  #   There can be as many asterisks as you need in the starting line, it only
  #   will change the hierarchy on the lines with todo words belonged to them,
  #   if there is not a todo keyword it will do nothing
  # }}}
  # Get main variables {{{

  # Get the current line
  var cur_line = getline('.')
  var line_number = line('.')
  var n = line_number
  var nlc = cur_line
  # }}}
  # While loop to find the line with titles {{{
  while n > 0
    nlc = getline(n)
    if nlc =~ '^\*'
      # echo 'Line ' .. string(n) .. ' is a title'
      break
    else
      n -= 1
    endif
  endwhile
  # }}}
  # Split line and check if the following word is a todo word {{{
  # Variable creation for the checking {{{

  var nlcs = split(nlc, ' ')
  var auxmenu: string
  var tdpval: string
  var tdpival: number
  var newst: string
  var tdval = index(g:org_todo_keywords, nlcs[1])
  # }}}
  if tdval >= 0
    # Check if it has a todo todo priorities section {{{
    if nlcs[2] =~ '\[\#.*\]'
      # echo 'Is a todo priorities title'
      # Trim argument to just take the letter and can verify {{{
      tdpval = trim(trim(nlcs[2], '\[\#'), '\]', 2)
      # Take index value
      tdpival = index(g:org_todo_priorities_list, tdpval)
      if tdpival == -1
        # echo 'Not a todo list element for the kind'
        newst = substitute(nlc, '\[\#.*\]', 
          '\[\#' .. g:org_todo_priorities_list[0] .. '\]', '')
        # echo newst
        
      elseif (tdpival - 1) == -1
        # echo 'This is the last element'
        newst = substitute(nlc, '\[\#.*\] ', '', '')
        # echo newst
      else
        # echo 'Element belongs to the list'
        newst = substitute(nlc, '\[\#.*\]', 
          '\[\#' .. g:org_todo_priorities_list[tdpival - 1] .. '\]', '')
        # echo newst
      endif
      # }}}
    else
      # echo 'Is a todo title without priorities'
      newst = substitute(nlc, 
        '\* ' .. g:org_todo_keywords[tdval], 
        '\* ' .. g:org_todo_keywords[tdval] .. ' \[\#'
        .. g:org_todo_priorities_list[-1] .. '\]', '')
      # echo newst
    endif
    # }}}
  else
    # echo 'is not a todo title'
      newst = substitute(nlc, 
        '\* ', 
        '\* ' .. g:org_todo_keywords[0] .. '\[\#' 
        .. g:org_todo_priorities_list[0] .. '\]', '')
      # echo newst
  endif
  # }}}
  # Inserts new line {{{
  append(n, newst)
  # }}}
  # Deletes the previous line {{{
  deletebufline('%', n)
  echo ''
  # }}}
enddef
#  }}}
# Additional functions {{{


def Insertpatitolol()
  # Remember [0,row,column,0]
  var curprev = getpos('.')
  var cline = curprev[1]
  var clcol = curprev[2]
  var curlc = getline(cline)
  var i = cline

  while i > 0
    
  endwhile
enddef


#  }}}
# Command creation {{{
# nnoremap <buffer> <Leader><S-Right> :OrgTODOTogglePriorUp<CR>
# nnoremap <buffer> <Leader><S-Left> :OrgTODOTogglePriorDwn<CR>
#  }}}
