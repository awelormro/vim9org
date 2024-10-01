vim9script
# vim: set fdm=marker:
# vim: set nospell:
g:org_sp_formula_sep = "{{{orgincommasep}}}"
g:org_sp_formula_list = [ 
  'vsum', 
  'vmean', 
  'vmax',
  'vmin', 
  'vmedian',
  'vconcat'
]

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
export def Org_enter_linkal()
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
          i = 2
          break
        endif
      elseif (cursor_column_sp[i] == ']' && cursor_column_sp[i - 1] == ']') ||
          (cursor_column_sp[i] == ']' && cursor_column_sp[i + 1] == ']')
        i -= 1000
        break
      elseif cursor_column_sp[i] == '[' && cursor_column_sp[i + 1] == '[' 
        i += 2
        break
      elseif cursor_column_sp[i] == '[' && cursor_column_sp[i - 1] == '[' 
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
          execute 'e ' .. full_path_file .. "/" .. link_name_start .. '.org'
    endif
  else
    echo 'Line does not contain links'
  endif
enddef

# }}}
command -buffer OrgEnterLinkal OrgEnterLinkal()
command -buffer OrgFindLinkPrev OrgFindLinkNext
nmap <buffer> <Leader><Leader>oll :OrgEnterLinkal<CR>
nmap <buffer> <Leader><Leader>oln :OrgFindLinkNext<CR>
nmap <buffer> <Leader><Leader>olp :OrgFindLinkPrevCR>
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
# Import section {{{
# ~/Plantillas/vim9org/autoload/spreadsheet/semanticsp.vim
# ~/Plantillas/vim9org/autoload/spreadsheet/lexersp.vim
import autoload "spreadsheet/lexersp.vim" as lxr
import autoload "base/counters/linecounters.vim" as lnc
import autoload "base/counters/stringcounters.vim" as snc
import autoload "spreadsheet/countformulas.vim" as cfr
import autoload "spreadsheet/spr.vim" as spr
import autoload "spreadsheet/semanticsp.vim" as sem
#  }}}
def TestFormulaValidation(tb: list<list<string>>, form: string): number
  # Description: Will test all the functions.
  # Main Things: {{{
  # - Validate formula X
  # - Type of formula X
  # - Expand formula if needed X
  # - Validate Ranges X
  # - Extract Data in a range isolated X
  # - Obtain lists of cell values, and range values in a Formua to extract
  #   isolated ones, and generate lists to search and lists 
  # - Replace data in formula(s)
  # - Obtain data
  # - Don't apply in headers or empty rows/cols if there are
  # - Replace data in correct places
  # - Execute Formula
  # - Replace in list in places
  # - Put error in case
  # }}}
enddef
def TestCases() # {{{

  var list_example_1 = [
    ['33', '33   ', ' 21 ', '  11  '],
    ['  22', '3.0     ', '       ', '4.5      '],
    ['  20', ' $ 3.50 ', '  33.50', '         '],
    ['  33', '13      ', '       ', '     33.4'],
    ['30  ', '    5   ', '6      ', '         ']
  ]

  var list_example_pos = [
    [ 'R1C1', 'R1C2', 'R1C3', 'R1C4', 'R1C5', ],
    [ 'R2C1', 'R2C2', 'R2C3', 'R2C4', 'R2C5', ],
    [ 'R3C1', 'R3C2', 'R3C3', 'R3C4', 'R3C5', ],
    [ 'R4C1', 'R4C2', 'R4C3', 'R4C4', 'R4C5', ],
    [ 'R5C1', 'R5C2', 'R5C3', 'R5C4', 'R5C5', ],
  ]

  var list_example_2 = [
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
  ]
  var formulas_example = [ 
    '@2$4=vmean(@2$3..@3$3,@3$4,$2,$2..$3,@3,@1..@3,,20,20)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Cell Formula
    '@4=vsum(@2$3..@3$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Row Formula
    '$4=vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Column Formula
    '@2$2..@3$3=vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Formula Range obtain
    '@4vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Wrong Formula
    '@1$3=vconcat(@1$1,@2$3)',
    '@3$2=vsum(vmean(2,4,vmin(44,22,$4,@3)),vmax(22,33,$2),vmin(12,14,$3,$5))+if("len(k)==3.5,4,0")' .. "'( + 2 3)"
  ]

  # echo formulas_example[6]
  # var test_all_function = cfr.CalculateFormulas(formulas_example[6], list_example_1)
  # var test_function = spr.TestSpread()
  # var test_lexer = lxr.LexerSp('E5:E&,B4 ,$ 3.50,$ 50.00,$4..$4,4+4.55-*/^min()E14:E15"Pendejada"cosas' .. "'")
  var test_lexer = lxr.LexerSp('sin(4.8)')
  echo test_lexer
  var test_semantic = sem.SemanticFunction( test_lexer, list_example_1 )
  echo test_semantic
enddef

# }}}
