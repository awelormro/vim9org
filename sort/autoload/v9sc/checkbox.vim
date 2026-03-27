" vim:set fdm=marker:
" vim:set nospell:
" vimscript part {{{
if !has('vim9script')
  finish
endif
" }}}
vim9script

export def ChecklistActions() #  {{{
  # Find line upwards if is a checkbox
  var line_start = line('.')
  var first_checkbox_detected = CheckLineCheckboxDown(line_start)
  if first_checkbox_detected == 0
    return
  endif
  # Toggle if checkbox detected
  ToggleLineChecklist(first_checkbox_detected)
  # Count checkboxes upwards and backwards and put if there are nested,
  def CheckBoxList(line_start: number): list<any>
    # Check lines above
    var i = line_start + 1
    var list_lines = []
    var last_line = line('$')
    while i < last_line
      var line_content = getline('.')
      if line_content =~ '^\s*\V- ['
        list_lines += [i]
        continue
      elseif line_content =~ '^\*' || line_content =~ '^\s*$'
        break
      else
        i += 1
      endif
    endwhile
    i = line_start - 1
    while i > 0
      var line_content = getline('.')
      if line_content =~ '^\s*\V- ['
        list_lines += [i]
        continue
      elseif line_content =~ '^\*' || line_content =~ '^\s*$'
        break
      else
        i -= 1
      endif
    endwhile
    return list_lines
  enddef
  var List_of_checkboxes = CheckBoxList(line_start)
  # Calculate tasks completed per task
  # If main task is completed, check all subtasks and mark lines
enddef # }}}

def CheckBoxList(line_number: number): list<any> # {{{
  # Each line must have if is 
  var i = 0
enddef # }}}

def CheckLineCheckboxDown(line_start: number): number # {{{
  var i = line_start
  while i > 0
    var line_content = getline(i)
    if line_content =~ '^\s*- \[[ X-]\]'
      return i
    elseif line_content =~ '^\s*$' || line_content '^\*'
      return 0
    endif
    i -= 1
  endwhile
enddef # }}}

def CheckCheckBoxUp(line_start: number): number # {{{
  var i = line_start
  var last_line = line('$')
  while i <= last_line
    i += 1
  endwhile
enddef # }}}

def ToggleLineChecklist(line_number: number) # {{{
  var line_content = getline(line_number)
  if line_content =~ '^\s*- \[ \] '
    var checkbox_toggled = substitute(line_content, '- \[ \]', '- \[X\]', "")
  elseif linecont =~ '^\s*- \[X\] '
    var checkbox_toggled = substitute(line_content, '- \[X\]', '- \[ \]', "")
  elseif linecont =~ '^\s*- \[-\] '
    var checkbox_toggled = substitute(line_content, '- \[-\]', '- \[X\]', "")
  endif
  setline(line_number, checkbox_toggled)
  return
enddef # }}}

export def ToggleChecklist() # {{{
  var i = line('.')
  while i > 0
    var linecont = getline(i)
    if linecont =~ '^\s*$'
      return
    endif
    if linecont =~ '^\s*- \[ \] '
      var checkbox_toggled = substitute(linecont, '- \[ \]', '- \[X\]', "")
      setline(i, checkbox_toggled)
      return
    elseif linecont =~ '^\s*- \[X\] '
      var checkbox_toggled = substitute(linecont, '- \[X\]', '- \[ \]', "")
      setline(i, checkbox_toggled)
      return
    elseif linecont =~ '^\s*- \[-\] '
      var checkbox_toggled = substitute(linecont, '- \[-\]', '- \[X\]', "")
      setline(i, checkbox_toggled)
      return
    endif
    i -= 1
  endwhile
enddef # }}}

def ChangeNumbersCheckbox(): # {{{
  var i = line('.')
  var line_content = getline(i)
  var indent_content = indent(line_content)
  var indent_prev = 700000000000000000000
  # Check Up for hierarchy
  # Check current line, if is a checkbox, check its structure
  if line_content =~ '^\s*- \[[\sX-]\]'
  endif
  while i > 0
    var linecont = getline(i)
    if getline(i) =~ '^\s*- \[ \]\s.*\[\d*/\d*\]$'
    elseif getline(i) =~ '^\s*- \[ \]\s.*\[\d*/\d*\]$'
    elseif getline(i) =~ '^\s*- \[ \]\s.*\[\d*/\d*\]$'
    elseif getline(i) =~ '^\s*- \[ \]\s.*\[\d*/\d*\]$'
    elseif getline(i) =~ '^\s*- \[ \]\s.*\[\d*/\d*\]$'
    endif
    i -= 1
  endwhile
enddef # }}}

