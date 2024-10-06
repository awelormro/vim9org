vim9script
# vim: set foldmethod=marker: 
# Update checkbox {{{
export def OrgCheckboxupdate()
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
export def OrgChecboxInsert()
  append(line('.'), '- [ ]  ')
  cursor(line('.') + 1, 7)
  startinsert
  execute "normal \<Right>"
  normal l
enddef
# }}}
# Update checkbox number {{{
export def UpdateNumberLists() # {{{
  var linen = line('.')
  var linec = getline(linen)
  if linec =~ '^\s*$'
cosa

if a ==1 
echo 1
    echo 'Empty line'
  endif
enddef # }}}
#  }}}
