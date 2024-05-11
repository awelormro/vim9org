vim9script
# vim: set fdm=marker:
# vim: set nospell:
# Function to obtain row part name
export def Partlist(linec1: string): string # {{{
  var table_parts = ['pipe separator', 'row', 'tbl header', 'tbl separator', 'formula line', 'none']
  var is_table1 = ''
  if linec1 =~ '^\s*|--' || linec1 =~ '^\s*|:-' 
    is_table1 = table_parts[0] 
  elseif linec1 =~ '^\s*|\w' || linec1 =~ '^\s*|\s*\w' || linec1 =~ '^\s*|\s*' 
    is_table1 = table_parts[1] 
  elseif linec1 =~ '^\s*+==' || linec1 =~ '^\s*+:=' 
    is_table1 = table_parts[2] 
  elseif linec1 =~ '^\s*+--' || linec1 =~ '^\s*+:-' 
    is_table1 = table_parts[3] 
  elseif linec1 =~ '^\s*#+TBLFM:' 
    is_table1 = table_parts[4] 
  else 
    is_table1 = table_parts[5] 
  endif
  return is_table1
enddef
# }}}
# Obtains The information of the kind of row or formula line a line is
export def IsTbOrFormula1(l: number): string # {{{
  # Line content in a string
  var lcont = getline(l)
  var kind = ''
  # Evaluate if line is a table row, header separator or a formula line
  # var table_parts = ['pipe separator', 'row', 'tbl header', 'tbl separator', 'formula line', 'none']
  if lcont =~ '|\s*\w' || lcont =~ '|\s*|'
    kind = 'row'
  elseif lcont =~ '|-*+'
    kind = 'pipe separator'
  # elseif lcont =~ '|\s*|'
  #   kind = 'row'
  elseif lcont =~ '+-*+' || lcont =~ '+:-*+' || lcont =~ '+:-*:+' || lcont =~ '+-*:+'
    kind = 'tbl separator'
  elseif lcont =~ '+=*+' || lcont =~ '+:=*+' || lcont =~ '+:=*:+' || lcont =~ '+=*:+'
    kind = 'tbl header'
  elseif lcont =~ '^\s*#+TBLFM:'
    kind = 'formula line'
  else
    kind = 'none'
  endif
  return kind
enddef
# }}}
# }}}
# Obtains the list of elements in the current table
export def KindsList(lst: list<number>): list<string> # {{{
  var cont = lst[0]
  var listels = []
  while cont <= lst[1]
    add(listels, IsTbOrFormula1(cont))
    cont += 1
  endwhile
  return listels
enddef
# }}}
# Loop to count lines until a condition for a part is given from start to end
export def CountLinesUp1(l: number, kinds: list<string>): number # {{{
  var counter = l
  while counter > 0
    if index(kinds, IsTbOrFormula1(counter)) > -1 && counter > 0
      counter -= 1
    elseif index(kinds, IsTbOrFormula1(counter)) == -1
      counter += 1
      break
    elseif IsTbOrFormula1(counter) == 'nothing'
      counter = -10
    else
      counter = -10
      break
    endif
  endwhile
  return counter
enddef
# }}}
# }}}
export def CountLinesDown(l: number, kinds: list<string>): number # {{{
  var counter = l
  while counter > 0
    if index(kinds, IsTbOrFormula1(counter)) > -1 && counter > 0
      counter += 1
    elseif index(kinds, IsTbOrFormula1(counter)) == -1
      counter -= 1
      break
    elseif IsTbOrFormula1(counter) == 'nothing'
      counter = -10
    else
      counter = -10
      break
    endif
  endwhile
  return counter
enddef
# }}}
# Obtain The type of table is 
export def TableType(lst: list<number>): string # {{{
  var tbl_type = ''
  if IsTbOrFormula1(lst[0]) == 'pipe separator' || IsTbOrFormula1(lst[0]) == 'row'
    tbl_type = 'pipe'
  else
    tbl_type = 'tbl'
  endif
  return tbl_type
enddef
# }}}
# Split the Table according to the type of row it has
export def SplitTable(tbinfo: list<number>): list<list<string>> # {{{
  var splittedtable = []
  var cont = tbinfo[0]
  while cont <= tbinfo[1]
    if IsTbOrFormula1(cont) == 'row'
      add(splittedtable, split(getline(cont), '|'))
    else
      add(splittedtable, split(getline(cont), '+'))
    endif
    cont += 1
  endwhile
  return splittedtable
enddef
# }}}
# Attempt to split into rows
export def SplitRow(tbinfo: list<number>): list<list<number>> #{{{
  var splittedrow = []
  return splittedrow
enddef
# }}}
# Split the formulas according to appearance
export def FormulasSplit1(tbinfo: list<number>): list<string> # {{{
  var splittedformulas = []
  var cont = tbinfo[2]
  while cont <= tbinfo[3]
    splittedformulas += split(trim(trim(getline(cont), '#+TBLFM:')), '::')
    cont += 1
  endwhile
  return splittedformulas
enddef
# }}}
# Obtain the number of cells with data in pipe tables 
export def Obtainpipetabledata(tbinfo: list<string>): list<number> # {{{
  var cont1 = 0
  var cellstable = []
  while cont1 < len(tbinfo)
    if tbinfo[cont1] == 'row'
      add(cellstable, cont1)
    endif
    cont1 += 1
  endwhile
  return cellstable
enddef # }}}
# Obtain the number of cells with data in tbl table
export def Obtaintbldata(tbinfo: list<string>): list<number>  # {{{
  var cellstable = []
  var seps = ['tbl header', 'tbl separator']
  var cont1 = 0
  while cont1 < len(tbinfo)
    if index(seps, tbinfo[cont1]) > -1 && cont1 < len(tbinfo) - 1
      add(cellstable, cont1 + 1)
    endif
    cont1 += 1
  endwhile
  return cellstable
enddef
# }}}
# Obtain the table type
export def ObtainTableData(tbinfo: list<string>, tbtype: string): list<number> # {{{
  var cellstable = []
  if tbtype == 'pipe'
    cellstable = Obtainpipetabledata(tbinfo)
  elseif tbtype == 'tbl'
    cellstable = Obtaintbldata(tbinfo)
  endif
  return cellstable
enddef
# }}}
# Split the formulas inside the table
export def ObtainFormulaLines(tb: list<list<string>>, formcols: list<number>): list<string> # {{{
  var cont1 = 0
  var cont2 = 0
  var listformulas = []
  while cont1 < len(tb)
    cont2 = 0
    while cont2 < len(tb[cont1])
      if trim(tb[cont1][cont2]) =~ '^:='
        add(listformulas, trim('@' .. string(cont1 + 1) .. '$' .. string(cont2 + 1) .. trim(tb[cont1][cont2])[1 : ]))
      endif
      cont2 += 1
    endwhile
    cont1 += 1
  endwhile
  return listformulas
enddef
# }}}
# Obtain the formulas inside a table 
export def GetFormulasInsideTable(tb: list<list<string>>, formcols: list<number>): list<string> # {{{
  var cont1 = 0
  var cont2 = 0
  var auxiliar_str = ''
  var formulalines = []
  var list_helper = []
  # Start to check all cells
  while cont1 < len(tb)
    # Restart on every new row
    #Restart loop in row
    # Before the second main loop, check if line is in the rows list
    if index(formcols, cont1) > -1
      cont2 = 0
      while cont2 < len(tb[cont1])
        # Check if the cell starts with :=
        if tb[cont1][cont2] =~ '^\s*:='
          auxiliar_str = '@' .. string(index(formcols, cont1) + 1) .. '$' .. string(cont2 + 1) .. '=' .. trim(tb[cont1][cont2])[2 :]
          add(formulalines, auxiliar_str)
        endif
        cont2 += 1
      endwhile
    endif
    cont1 += 1
  endwhile
  return formulalines
enddef
# }}}
# Obtain The data info, if is a specific cell, a row, a column or an arrange
export def ObtainFormulaKind(formul: string): string # {{{
  var rangeformula = ''
  var kindsformulas = ['cell formula', 'row formula', 'column formula', 'range formula', 'error']
  if trim(formul) =~ '^@\d*\$\d*='
    rangeformula = kindsformulas[0]
  elseif trim(formul) =~ '^\$\d*='
    rangeformula = kindsformulas[1]
  elseif trim(formul) =~ '^@\d*='
    rangeformula = kindsformulas[2]
  elseif trim(formul) =~ '^@\d*\$\d*\.\.@\d*\$\d*='
    rangeformula = kindsformulas[3]
  else
    rangeformula = kindsformulas[4]
  endif
  return rangeformula
enddef
# }}}
# Function to generate the matrix for allowed cells as being used
export def GenerateCellMatrix(tb: list<list<string>>, rowlines: list<number>): list<list<string>> # {{{
  var i = 0
  var j = 0
  var listall = []
  var currow = []
  while i < len(tb)
    if index(rowlines, i) > - 1
      add(listall, tb[i])
    endif
    i += 1
  endwhile
  return listall
enddef
# }}}
# Function to substitute ranges inside tables
export def SubstituteTangesInTable(tb: list<list<string>>, formula: string): list<string> # {{{
  # Declare main variables {{{
  var i = 0
  var j = 0
  var rangeskinds = ['row', 'column', 'range', 'cell']
  var start_range = ''
  var listed_parts = ''
  var substitute_string = split(formula, '\zs')
  # }}}
  # Obtain the formula type {{{
  if formula =~ '^@\d*\$\d*='
    # If is @3$5=, will be on row 3, column 5
    start_range = rangeskinds[3]
  elseif formula =~ '^@\d*\$\d*\.\.@\d*\$\d*='
    # If is @3$5..@4$5=, will be from row 3, column 5 to row 4, column 5
    start_range = rangeskinds[2]
  elseif formula =~ '^@\d*='
    # If is @3=, will be on row 3, for all non empty cells or header on that row
    start_range = rangeskinds[0]
  elseif formula =~ '^@\d*='
    # If is $3=, will be on col 3, for all non empty cells or header on that row
    start_range = rangeskinds[1]
  endif
  # }}}
  # Depending on the formula type, it must act differently, 
  if start_range == 'row'
    # Check the formula and start to obtain data {{{
    # }}}
  endif
enddef
# }}}
# Function to generate a matrix with all data types
export def GenerateDataTypeMatrix(tb: list<list<string>>): list<list<string>> # {{{
  var i = 0
  var j = 0
  var kind_cells = ['Text', 'Header', 'Separator', 'Number', 'Float', 'Currency', 'Empty']
  var type_cell = ''
  var typecells = []
  var rowlist = []
  # Lambda to define cell type, might be one of the kinds in the list
  var DefineCell = (cell: string): string => { # {{{
    var kindcells = ['Text', 'Header', 'Separator', 'Number', 'Float', 'Currency', 'Empty', 'Formula']
    var typecell = ''
    if cell =~ '^\s*$'
      typecell = kindcells[-1]
    elseif cell =~ '^\s*\a'
      typecell = kindcells[0]
    elseif cell =~ '^:-' || cell =~ '^--' || cell =~ '^|-' 
      typecell = kindcells[2]
    elseif cell =~ '^==' || cell =~ '^:='
      typecell = kindcells[1]
    elseif cell =~ '^\s*\d*\s*$'
      typecell = kindcells[3]
    elseif cell =~ '^\s*\d*\.\d*\s*$'
      typecell = kindcells[4]
    elseif cell =~ '^\s*[\$€¥]\s\d*\.\d*\s*$'
      typecell = kindcells[5]
    elseif cell =~ '^\s*:=\w'
      typecell = kindcells[6]
    else
      typecell = kindcells[-1]
    endif
    return typecell
  }
  # }}}
  while i < len(tb)
    j = 0
    rowlist = []
    while j < len(tb[i])
      type_cell = DefineCell(tb[i][j])
      add(rowlist, type_cell)
      j += 1
    endwhile
    add(typecells, rowlist)
    i += 1
  endwhile
  return typecells
enddef
# }}}
# Function to generate a list for rows with more than a header in text or with text
export def ListOfElementsInRows(tb: list<list<string>>): list<string> # {{{
  var i = 0
  var j = 0
  var list_data_in_cells = []
  var kind_of_data_row = []
  var maxkind = 0
  var kinds_of_data_in_row = [ 'Only First', 'Empty', 'Numbers', 
    'Text', 'Float', 'Currency', 'More Formulas', 'Header']
  var kinds = [0, 0, 0, 0, 0, 0, 0]
  var kind_cells = ['Text', 'Header', 'Separator', 'Number', 'Float', 'Currency', 'Empty']
  while i < len(tb)
    kinds = [
      count(tb[i], kind_cells[0]), 
      count(tb[i], kind_cells[1]), 
      count(tb[i], kind_cells[2]), 
      count(tb[i], kind_cells[3]), 
      count(tb[i], kind_cells[4]), 
      count(tb[i], kind_cells[5]), 
      count(tb[i], kind_cells[6]), 
    ]
    maxkind = index(kinds, max(kinds))
    add(list_data_in_cells, kind_cells[maxkind])
    i += 1
  endwhile
  return list_data_in_cells
enddef
# }}}
# Function to obtain the columns as followed lists for ease the use
export def TransposeTable(tb: list<list<string>>): list<list<string>> # {{{
  var i = 0
  var j = 0
  var tblo = []
  var coltb = []
  while j < len(tb[0])
    i = 0
    coltb = []
    while i < len(tb)
      add(coltb, tb[i][j])
      i += 1
    endwhile
    add(tblo, coltb)
    j += 1
  endwhile
  return tblo
enddef
# }}}
# Function to check if is a row, column, range or cell formula
export def CheckFormulaType(formula: string): string # {{{
  var type_formula = ''
  # var formula_start = split(formula, '=')
  var formula_types = ['Row', 'Column', 'Range', 'Cell']
  if formula =~ '^@\d*\$\d*='
    type_formula = formula_types[-1]
  elseif formula =~ '^@\d*='
    type_formula = formula_types[0]
  elseif formula =~ '^\$\d*='
    type_formula = formula_types[1]
  elseif formula =~ '^@\d*\$\d*\.\.@\d*\$\d*='
    type_formula = formula_types[2]
  endif
  return type_formula
enddef
# }}}
# Function to obtain all the formula types in all kinds
export def CheckAllFormulaTypes(frmlas: list<string>): list<string> # {{{
  var list_frms = []
  var auxiliar_str = ''
  for form in frmlas
    auxiliar_str = CheckFormulaType(form)
    add(list_frms, auxiliar_str)
  endfor
  return list_frms
enddef
# }}}
# Function to make the formulas in case of row formulas
export def GenerateRowFormulas(tb: list<list<string>>, tbkinds: list<list<string>>, frmla: string): list<string> # {{{
  # Obtain the row to check the formula.
  # Example: @5=sum(@4..@5)
  var splitted_formula = split(frmla, '=')
  var list_frmlas = []
  # Obtain the row it will be added
  var ObtainRow = str2nr(splitted_formula[0][1 :]) - 1
  # Start a variable to add into the loop for all rows
  var i = 0
  var auxstring = ''
  while i < len(tb[0])
    auxstring = '@' .. string(ObtainRow) .. '$' .. string(i + 1) .. '=' .. splitted_formula[1]
    add(list_frmlas, auxstring)
    i += 1
  endwhile
  return list_frmlas
enddef
# }}}
# Function to make the formulas in case or column formulas
export def GenerateColFormulas(tb: list<list<string>>, tbkinds: list<list<string>>, frmla: string): list<string> # {{{
  # Obtain the row to check the formula.
  # Example: @5=sum(@4..@5)
  var splitted_formula = split(frmla, '=')
  var list_frmlas = []
  # Obtain the row it will be added
  var ObtainCol = str2nr(splitted_formula[0][1 :]) - 1
  # Start a variable to add into the loop for all rows
  var i = 0
  var auxstring = ''
  while i < len(tb)
    auxstring = '@' .. string(i + 1)   .. '$' .. string(ObtainCol) .. '=' .. splitted_formula[1]
    add(list_frmlas, auxstring)
    i += 1
  endwhile
  return list_frmlas
enddef
# }}}
# Main Function Example to make a threatment of formulas
export def ChangeCellCols() # {{{
  # Example table list
  var listExample = [
    ['  Texto', 'Texto   ', '  Texto  '],
    ['  Texto', '3', '4'],
    ['  Texto', '3', '4'],
    ['  Texto', '13', '14'],
    ['Texto', '5', '6']
  ]
  # Example formula
  # var FormulaExample = '@3$2=vsum($2..$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)'
  # var FormulaExample = '@3$2=vsum($2..$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)'
  var FormulaExample = '$2=vsum($2..$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)'
  var ListAllSymbols = ['$', '@', '=', '+', '-', '/', '*', '^', '(', ')', '..', "'("]
  var type_cells = [ 'Text', 'Number', 'Float', 'Currency', 'Empty' ]
  var type_cell_del = [ '^\s*\a*', '^\s*\d*\s*$', '^\s*\d*\.\d*\s*$', '^\s*\$\s\d*\.\d*\s*$' '^\s*$' ]
  var ListAllFormulas = ['vsum', 'vmean', 'vmin', 'vmax']
  var ListElispFormulas = ['concat', '']
  var LisSymbolPos = []
  # List with row and column length, using always the very first column as the
  # parameter
  var MainLens = [ len(listExample), len(listExample[0]) ]
  var auxlist = []
  for symbol in ListAllSymbols
    auxlist = ListSymbolInFormula(FormulaExample, symbol)
    add(LisSymbolPos, auxlist)
    auxlist = []
  endfor
  echo LisSymbolPos
  var canexexute = len(LisSymbolPos[2])
  # check The formula position with the very first @ and $, before the equal
  # symbol, if at symbol first is greater than the first equal symbol but the
  # very first dollar symbol is lower, it will be a symbol formula.
  if len(canexexute) > 0
    if LisSymbolPos[0][0] < LisSymbolPos[2][0] && LisSymbolPos[1][0] < LisSymbolPos[2][0] 
      canexexute = 1
    elseif LisSymbolPos[0][0] < LisSymbolPos[2][0]
      canexexute = 2
    elseif LisSymbolPos[1][0] < LisSymbolPos[2][0]
      canexexute = 3
    else
      canexexute = 0
    endif
  endif
enddef
# }}}
# Auxiliar Functions to threat the data
# Function to count the expected symbol {{{
export def ListSymbolInFormula(formula: string, symb: string): list<number>
  var i = 0
  var listsymbol = []
  var straux = 0
  while i > -1
    if stridx(formula, symb, i) > -1
      straux = stridx(formula, symb, i)
      add(listsymbol, straux)
      i = straux + 1
    else
      break
    endif
  endwhile
  return listsymbol
enddef
g:Pendejadaleatoria = 'Cosas'
#  }}}
