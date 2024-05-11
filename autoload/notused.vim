vim9script
# vim: set fdm=marker:
# vim: set nospell:

def OrgTableLengths(tablecells: list<list<string>>, lns: list<list<number>>) 
# Check max length and put all the strings with that {{{
  # Logic of this part: {{{
  # - Check the length of each column
  # - If the length is the max, put it into a counter
  # - If string does not start with space, append space at start
  # - if string has length below, check if starts with space and append spaces
  #   until reach length
  # }}}
  var i = 0
  var j = 0
  var maxlen = 0
  var lenstr = 0
  var indexappend = []
  var rowappend = []
  var lenlist = []
  # loop to start checking the conditions
  while i < len(tablecells[0])
    j = 0
    maxlen = 0
    while j < len(tablecells)
      if strlen(tablecells[j][i]) > maxlen
        maxlen = strlen(tablecells[j][i])
      endif
      j += 1
    endwhile
    insert(lenlist, maxlen)
    i += 1
  endwhile
  lenlist = reverse(lenlist)
  echo lenlist
  # check every cell and append spaces if it does not have at the beginning or
  # the end
  i = 0
  j = 0

enddef #  }}}
def Orgtablelens(tablecells: list<list<string>>): list<list<number>> # Obtain lenghts of each cell {{{
  var i = 0
  var listall = []
  var listrow = []
  var listrrowrev = []
  var listallrev = []
  for row in tablecells
    listrow = []
    i = 0
    while i < len(row)
      # echo row[1]
      # echo strlen(row[i])
      insert(listrow, strlen(row[i]))
      i += 1
    endwhile
    insert(listall, reverse(listrow))
  endfor
  return reverse(listall)
enddef
#  }}}
def OrgTableconstitution(): list<list<string>> # Orgmode table content {{{
  var line_number = line('.')
  var line_content = getline('.')
  var prevlineflag: number
  var nextlineflag: number
  var firsttableline: number 
  var lasttableline: number
  var tablecontents = []
  var rowcontents: list<string>
  var reversedlist: list<list<string>>
  # echo type(line_number)

  if line_number != 1
    prevlineflag = 1
  endif
  if line_number != line('$')
    nextlineflag = 1
  endif
  var i = line_number
  # Run up
  if prevlineflag == 1
    while i > 0
      if (getline(i) =~ '^\s*|') || (getline(i) =~ '^\s*+-') || (getline(i) =~ '^\s*+=')
        i -= 1
      else
        break
      endif
    endwhile
    echo i
  endif
  i += 1
  while i > 0
    if getline(i) =~ '^\s*|'
      rowcontents = split(getline(i), '|')
      # echo rowcontents
      insert(tablecontents, rowcontents)
      i += 1
    elseif getline(i) =~ '^\s*+-'
      rowcontents = split(getline(i), '+')
      # echo rowcontents
      insert(tablecontents, rowcontents)
      i += 1
    elseif getline(i) =~ '^\s*+='
      rowcontents = split(getline(i), '+')
      insert(tablecontents, rowcontents)
      # echo rowcontents
      i += 1
    else
      break
    endif
  endwhile
  # echo tablecontents
  reversedlist = reverse(tablecontents)
  # echo reversedlist
  return reversedlist
enddef

#  }}}
export def OrgNewcol() # Add new column {{{
  # Logic on this part: {{{
  # - Read the current line and check if starts with pipe, +- or +=
  # - Check in previous line if there is a pipe at start or +- or +=
  # - Same for following line with pipe, +- or += 
  # - If true:
  #   - If starts with pipe or plus:
  #     - count all chars ultil the next pipe or +
  #     - Add spaces to fill until the pipe or plus in the next line
  #     - Add pipe to fill the line
  #   
  #
  # }}}
  var allcells = OrgTableconstitution()
  echo allcells
  var alllens = Orgtablelens(allcells)
  echo alllens
  OrgTableLengths(allcells, alllens)
enddef

# }}}
export def OrgAddRow() # {{{ Add a row below
  # Logic for this section{{{
  # - Read the current line
  # - Check if it is a table section, based on two statements:
  #   1. The line starts and ends with |
  #   2. The line only contains +- or += for headers or separators
  # - If the line starts with spac
  # }}}
  var line_content = getline('.')
  var line_content_sp = split(line_content, '|')
  var newcol = ''
  var spcol: number
  var cellspl: number
  if line_content =~ '\|$' && line_content =~ '^\|'
    echo 'line has a bar at the end'
    echo line_content_sp
    for cell in line_content_sp
      newcol = '|' .. repeat(' ', strlen(cell)) .. ' '
    endfor
    newcol = newcol .. '|'
    append(line('.'), newcol)
  endif
  # if line_content =~ '^\|'
  #   echo 'Line starts with a bar at start'
  # endif
enddef

# }}}

# Orgmode Spreadsheet begin {{{

def IsTableOrFormula(li: number): string # {{{
  var whatis = ''
  if getline(li) =~ '^\s*+=' || getline(li) =~ '^\s*+-' || getline(li) =~ '^\s*+:=' ||
     getline(li) =~ '^\s*+:=' || getline(li) =~ '^\s*+:-' || getline(li) =~ '^\s*|\s' || getline(li) =~ '^\s*|\w' 
    whatis = 'table'
  elseif getline(li) =~ '^\s*#+TBFM'
    whatis = 'formulas'
  else 
    whatis = 'none'
  endif
  return whatis
enddef

#  }}}
def OrgSpreadsheetCountLineFormulas(ln: number): list<number> # {{{
  var j = ln
  var forbeg = 0
  var forend = 0
  var lisaux = []
  var lisforms = []
  while j > -10
    if getline(j) =~ '^\s*#+TBFM:'
      j -= 1
    elseif IsTableOrFormula(j) == 'table'
      forbeg = j + 1
      j = ln
      break
    elseif IsTableOrFormula(j) == 'none'
      forbeg = 0
      forend = 0
      j = -1000
      break
    endif
  endwhile
  while j > -10
    if IsTableOrFormula(j) == 'formulas'
      j += 1
    else
      forend = j - 1
      break
    endif
  endwhile
  lisaux = [forbeg, forend]
  # echo lisaux
  return lisaux
enddef
#  }}}
def OrgSpreadsheetCountLineTable(ln: number): list<number> # {{{
  var i = ln
  var tbeg = 0
  var tend = 0
  var auxlist = []
  while i > -10
    if IsTableOrFormula(i) == 'table'
      i -= 1
    elseif i == 0
      break
    elseif IsTableOrFormula(i) == 'none'
      tbeg = i + 1
      break
    endif
  endwhile
  i = ln
  while i > -10
    if IsTableOrFormula(i) == 'table'
      i += 1
    else
      tend = i - 1
      break
    endif
  endwhile
  auxlist = [tbeg, tend]
  # echo auxlist
  return auxlist
enddef
#  }}}
def OrgSpreadsheetDelimsandformulas(): list<any> # {{{
  var linen = line('.')
  var wut = IsTableOrFormula(linen)
  var i = linen
  var lisforms = []
  # auxconsts
  var auxlist1 = []
  var auxlist = []
  var lisfin = []
  if wut == 'table'
    # echo 'scan table'
    auxlist1 = OrgSpreadsheetCountLineTable(linen)
    auxlist = OrgSpreadsheetCountLineFormulas(auxlist1[1] + 1)
    lisfin = [auxlist1[0], auxlist1[1], auxlist[0], auxlist[1]]
  elseif wut == 'formulas'
    # echo 'line has formulas'
    lisforms = OrgSpreadsheetCountLineFormulas(linen)
    auxlist1 = OrgSpreadsheetCountLineTable(lisforms[0] - 1)
    lisfin = [auxlist1[0], auxlist1[1], lisforms[0], lisforms[1]]
  endif
  # echo auxlist1
  # echo lisforms
  # echo lisfin
  return lisfin
enddef

#  }}}
def OrgSpreadsheetFormulaLineSplit(ln: number): list<string> # {{{
  var i = 0
  var linec = getline(ln)
  var linesp = trim(trim(linec, '#+TBFM:'))
  var lformulas = split(linesp, '::')
  # echo lformulas
  return lformulas
enddef

#  }}}
def OrgSplitFormulas(linforms: list<number>): list<list<string>> # {{{
  var listformulas = []
  var i = linforms[2]
  var listaux = []
  var listforms = []
  while i <= linforms[3]
    listforms = OrgSpreadsheetFormulaLineSplit(i)
    add(listformulas, listforms)
    i += 1
  endwhile
  # echo listformulas
  return listformulas
enddef
#  }}}
def OrgSpeadsheetSplit(tbinfo: list<number>): list<list<string>> # {{{
  var tb = []
  var tbr = []
  var i = tbinfo[0]
  var wut = ''
  while i <= tbinfo[1]
    if tbl.IsColumnOrHeader(getline(i)) == 'header'
      tbr = split(getline(i), '+')
      add(tb, tbr)
    elseif tbl.IsColumnOrHeader(getline(i)) == 'column'
      tbr = split(getline(i), '|')
      add(tb, tbr)
    endif
    i += 1
  endwhile
  return tb
enddef
# }}}
def OrgSpreadsheetIsPipeOrTbl(tb: list<list<string>>): string # {{{
  var kindtable = ''
  if tb[0][0] =~ '^-*$' || tb[0][0] =~ '^:-*$' || tb[0][0] =~ '^-*:$' || tb[0][0] =~ '^:-*:$'
    kindtable = 'tbl'
  else
    kindtable = 'pipe'
  endif
  return kindtable
enddef
# }}}
def OrgSpreadsheetDetectRowOrColumn(form: list<string>): list<number> # {{{
  if form =~ '@\n*'

  endif
enddef
# }}}
# For the moment, it will take the very first item for tbl.org tables as the
# main variable argument
def OrgSpreadsheetCheckHeader(tb: list<list<string>>): number # {{{
  var i = 0
  var headerbeg = -10
  while i < len(tb)
    if tb[i][0] =~ '^=*$' || tb[i][0] =~ '^:=*$' || tb[i][0] =~ '^=*:$' || tb[i][0] =~ '^:=*:$'
      headerbeg = i
      echo 'Table has a header'
      i = 0
      break
    else
      i += 1
    endif
  endwhile
  return headerbeg
enddef # }}}
def OrgSpreadsheetCheckRows(tb: list<list<string>>): list<number> # {{{
  var i = 0
  var celheaders = []
  while i < len(tb)
    if tb[i][0] =~ '^-*$' || tb[i][0] =~ '^:-*$' || tb[i][0] =~ '^-*:$' || tb[i][0] =~ '^:-*:$'
      add(celheaders, i)
    endif
    i += 1
  endwhile
  return celheaders
enddef # }}}
def OrgSpreadsheetFormulaWhichCells(tb: list<list<string>>, kind: string): list<list<string>> # {{{
  var i = 0
  var j = 0
  var headerbeg = -10
  var begrow = 0
  var endrow = 0
  var cellrow = 0
  var listv = []
  var listheaders = []
  var auxlist = []
  if kind == 'pipe'
    if tb[1][0] =~ '^-*$' || tb[1][0] =~ '^:-*$' || tb[1][0] =~ '^-*:$' || tb[1][0] =~ '^:-*:$'
      # listvalues = tb[2 : ]
      i = 2
    else
      i = 0
    endif
    while i < len(tb)
      add(listv, tb[i])
      i += 1
    endwhile
  elseif kind == 'tbl'
    # Check if the table has header
    headerbeg = OrgSpreadsheetCheckHeader(tb)
    echo headerbeg
    listheaders = OrgSpreadsheetCheckRows(tb)
    echo listheaders
    i = 0
    # auxlist = listheaders[1 :]
    if headerbeg > 0
      add(auxlist, headerbeg)
    endif
    while i < len(listheaders)
      if listheaders[i] > headerbeg
        add(auxlist, listheaders[i])
      endif
      i += 1
    endwhile
    if listheaders[-1] + 1 == len(tb)
      auxlist = auxlist[: -2]
      echo 'last separator is last line in table'
    endif
    echo listheaders
    i = 0
    while i < len(auxlist)
      add(listv, tb[auxlist[i] + 1])
      i += 1
    endwhile
    # while i < len(listheaders)
    #   if listheaders[i] > headerbeg
        
    #   endif
    # endwhile
  endif
  echo auxlist
  # echo tb
  return listv
enddef # }}}
export def OrgCalculateFomulas() # {{{
  # Logical issues {{{
  # - First, split table into cells using methods checked before
  # - MUST have the #+TBFORM
  # - Priority will be: First execute every formula in TBFM from first to last
  # - Secondly, the formulas in cells inside table
  # }}}
  # List of begining and end of Formulas and table
  var firstdata = OrgSpreadsheetDelimsandformulas()
  # echo firstdata
  # Split formulas into a list of lists
  var formulas = OrgSplitFormulas(firstdata)
  # echo formulas
  # Split table into cells
  var splittable = OrgSpeadsheetSplit([firstdata[0], firstdata[1]])
  # echo splittable
  var kindtable = OrgSpreadsheetIsPipeOrTbl(splittable)
  # echo kindtable
  # Obtain the values in a table, it will search in cases for pipe or tbl
  # formulas
  var tablevalues = OrgSpreadsheetFormulaWhichCells(splittable, kindtable)
  echo tablevalues
enddef #  }}}
#  }}}

# Function to generate the matrix for allowed cells as being used
def GenerateCellMatrix(tb: list<list<string>>, rowlines: list<number>): list<list<string>> # {{{
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
def SubstituteTangesInTable(tb: list<list<string>>, formula: string): list<string> # {{{
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
def GenerateDataTypeMatrix(tb: list<list<string>>): list<list<string>> # {{{
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
def ListOfElementsInRows(tb: list<list<string>>): list<string> # {{{
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
def TransposeTable(tb: list<list<string>>): list<list<string>> # {{{
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
def CheckFormulaType(formula: string): string # {{{
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
def CheckAllFormulaTypes(frmlas: list<string>): list<string> # {{{
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
def GenerateRowFormulas(tb: list<list<string>>, tbkinds: list<list<string>>, frmla: string): list<string> # {{{
  # Obtain the row to check the formula.
  # Example: @5=sum(@4..@5)
  var splitted_formula = split(frmla, '=')
  var list_frmlas = []
  var ObtainRanges = str2nr(splitted_formula[0][1 :]) - 1
  var i = 0
  var auxstring = 
  while i < ObtainRanges
    add(list_frmlas)
  endwhile
enddef
# }}}

  # Useful lambdas creation {{{
  # Lambda to obtain row part name
  var Partlist = (linec1) => { # {{{
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
  }
  # }}}
  # Obtains The information of the kind of row or formula line a line is
  var IsTbOrFormula1 = (l): string => { # {{{
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
  }
  # }}}
  # Obtains the list of elements in the current table
  var KindsList = (lst: list<number>): list<string> => { # {{{
    var cont = lst[0]
    var listels = []
    while cont <= lst[1]
      add(listels, IsTbOrFormula1(cont))
      cont += 1
    endwhile
    return listels
  } # }}}
  # Loop to count lines until a condition for a part is given from start to end
  var CountLinesUp1 = (l: number, kinds: list<string>): number => { # {{{
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
  }
  # }}}
  var CountLinesDown = (l: number, kinds: list<string>): number => { # {{{
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
  }
  # }}}
  # Obtain The type of table is 
  var TableType = (lst: list<number>): string => { # {{{
    var tbl_type = ''
    if IsTbOrFormula1(lst[0]) == 'pipe separator' || IsTbOrFormula1(lst[0]) == 'row'
      tbl_type = 'pipe'
    else
      tbl_type = 'tbl'
    endif
    return tbl_type
  }
  # }}}
  # Split the Table according to the type of row it has
  var SplitTable = (tbinfo: list<number>): list<list<string>> => { # {{{
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
  }
  var SplitRow = (tbinfo: list<number>): list<list<number>> => {
    var splittedrow = []
    return splittedrow
  }
  # var  = 
  # }}}
  # Split the formulas according to appearance
  var SplitFormulas = (tbinfo: list<number>): list<string> => { # {{{
    var splittedformulas = []
    var cont = tbinfo[2]
    while cont <= tbinfo[3]
      splittedformulas += split(trim(trim(getline(cont), '#+TBLFM:')), '::')
      cont += 1
    endwhile
    return splittedformulas
  }
  # }}}
  # Obtain the number of cells with data in pipe tables 
  var Obtainpipetabledata = (tbinfo: list<string>): list<number> => { # {{{
    var cont1 = 0
    var cellstable = []
    while cont1 < len(tbinfo)
      if tbinfo[cont1] == 'row'
        add(cellstable, cont1)
      endif
      cont1 += 1
    endwhile
    return cellstable
  } # }}}
  # Obtain the number of cells with data in tbl table
  var Obtaintbldata = (tbinfo: list<string>): list<number> => { # {{{
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
  }
  # }}}
  # Obtain the number of cells with data, depending on if is tbl or pipe table
  var ObtainTableData = (tbinfo: list<string>, tbtype: string): list<number> => { # {{{
    var cellstable = []
    if tbtype == 'pipe'
      cellstable = Obtainpipetabledata(tbinfo)
    elseif tbtype == 'tbl'
      cellstable = Obtaintbldata(tbinfo)
    endif
    return cellstable
  }
  # }}}
  # Split the formulas inside the table
  var ObtainFormulaLines = (tb: list<list<string>>, formcols: list<number>): list<string> => { # {{{
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
  }
  # }}}
  # Obtain the formulas inside a table 
  var GetFormulasInsideTable = (tb: list<list<string>>, formcols: list<number>): list<string> => { # {{{
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
  }
  # }}}
  # Obtain The data info, if is a specific cell, a row, a column or an arrange
  var ObtainFormulaKind = (formul: string): string => { # {{{
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
  }
  # }}}
  # Obtain the ranges of formulas
  # var RangesOfFormulas = (tb: list<list<string>>, formuls: list<string>, lformuls: list<number>): list<string> => { # {{{
  #   var kindsformulas = ['cell formula', 'row formula', 'column formula', 'range formula', 'error']
  #   var cont1 = 0
  #   var cont2 = 0
  #   while cont1 < len(formuls)
  #   endwhile
  # }
  # }}}
  # }}}

# Rearrange for Spreadsheet Readability {{{
# Checker for Tables is a formula, a separator or a row
# Formulas to verify parts {{{
# Function used to check if is a pipe table or a org-tbl table
def IsTbOrFormula(l: number): string # {{{
  # Line content in a string
  var lcont = getline(l)
  var kind = ''
  # Evaluate if line is a table row, header separator or a formula line
  if lcont =~ '|\s*\w' || lcont =~ '|\s*|'
    kind = 'row'
  elseif lcont =~ '|-*+'
    kind = 'pipe header sep'
  # elseif lcont =~ '|\s*|'
  #   kind = 'row'
  elseif lcont =~ '+-*+' || lcont =~ '+:-*+' || lcont =~ '+:-*:+' || lcont =~ '+-*:+'
    kind = 'tbl sep'
  elseif lcont =~ '+=*+' || lcont =~ '+:=*+' || lcont =~ '+:=*:+' || lcont =~ '+=*:+'
    kind = 'tbl header'
  elseif lcont =~ '^\s*#+TBLFM:'
    kind = 'formula'
  else
    kind = 'nothing'
  endif
  return kind
enddef # }}}
#  }}}
# Functions To count recursive parts {{{
# Count Lines of specific kind up, break if gets another thing
def CountLinesUp(l: number, kinds: list<string>): number # {{{
  var i = l
  while i > 0
    if index(kinds, IsTbOrFormula(i)) > -1 && i > 0
      i -= 1
    elseif index(kinds, IsTbOrFormula(i)) == -1
      i += 1
      break
    elseif IsTbOrFormula(i) == 'nothing'
      i = -10
    else
      i = -10
      break
    endif
  endwhile
  return i
enddef # }}}
# Count Lines of specific kind down, break if gets another thing
def CountLinesDown(l: number, kinds: list<string>): number # {{{
  var i = l
  while i > 0
    if index(kinds, IsTbOrFormula(i)) > -1 && i > 0
      i += 1
    elseif index(kinds, IsTbOrFormula(i)) == -1
      # i -= 1
      break
    elseif IsTbOrFormula(i) == 'nothing'
      i = -10
      break
    else
      i = -10
      break
    endif
  endwhile
  return i
enddef # }}}
# Count lines of formulas function
def CountLineFormulas(l: number): list<number> # {{{
  var forms = ['formula']
  var tbeg = CountLinesUp(l, forms)
  var tend = CountLinesDown(l, forms)
  return [tbeg, tend]
enddef # }}}
# Function to count table functions
def CountLineTbl(l: number): list<number> # {{{
  var tableparts = [ 'pipe header sep', 'row', 'tbl sep', 'tbl header']
  var tbeg = CountLinesUp(l, tableparts)
  var tend = CountLinesDown(l, tableparts)
  return [tbeg, tend]
enddef # }}}
# Count Lines of tables and formulas, will send negative values for every kind
# it does not acknowledge or can detect
def CountTbandFormulas(l: number): list<number> # {{{
  var linec = getline(l)
  var kind = IsTbOrFormula(l)
  var flagexp = ''
  var tbparts = []
  var foparts = []
  var fiparts = []
  var tableparts = [ 'pipe header sep', 'row', 'tbl sep', 'tbl header']
  if index(tableparts, kind) > -1
    echo 'This part begins a table section'
    tbparts = CountLineTbl(l)
    if IsTbOrFormula(tbparts[1] + 1) == 'nothing' || tbparts[0] == 1
      foparts = [-10, -10]
    else
      foparts = CountLineFormulas(tbparts[1] + 1)
    endif
  elseif kind == 'formula'
    echo 'This part begins a formula section'
    foparts = CountLineFormulas(l)
    if IsTbOrFormula(foparts[0] - 1) == 'nothing' || foparts[0] == 1
      tbparts = [-10, -10]
    else
      tbparts = CountLineTbl(foparts[0] - 1)
    endif
  endif
  echo foparts
  echo tbparts
  fiparts = tbparts + foparts
  echo fiparts
  return fiparts
enddef # }}}
#  }}}
# Check if the table is a Tbl.org table or a pipe table
def IsTblOrPipe(ltbl: list<number>): string # {{{
  var tableparts = [ 'pipe header sep', 'row', 'tbl sep', 'tbl header']
  var flcont = getline(ltbl[0])
  var kind = ''
  if index(tableparts, IsTbOrFormula(ltbl[0])) == 0 || index(tableparts, IsTbOrFormula(ltbl[0])) == 1
    kind = 'pipetable'
  elseif index(tableparts, IsTbOrFormula(ltbl[0])) == -1
    return 'not'
  else
    kind = 'tbl'
  endif
  return kind
enddef
# }}}
# Split the table into individual cells to evaluate it
def SplitTbl(ltbl: list<number>): list<list<string>> # {{{
  var tableparts = [ 'pipe header sep', 'row', 'tbl sep', 'tbl header']
  var listtotal = []
  var listrow = []
  var i = ltbl[0]
  while i <= ltbl[1]
    if index(tableparts, IsTbOrFormula(i)) == 1
      listrow = split(getline(i), '|')
    else
      listrow = split(getline(i), '+')
    endif
    add(listtotal, listrow)
    i += 1
  endwhile
  return listtotal
enddef # }}}
# Split the table into individual cells to check and evaluate every one
def SplitFormulas(lformulas: list<number>): list<string> # {{{
  var listtotal = []
  var listrow = []
  var straux = ''
  var i = lformulas[2]
  while i <= lformulas[3]
    straux = trim(trim(getline(i), '#+TBLFM:'))
    listrow = split(straux, '::')
    listtotal += listrow
    # add(listtotal, listrow)
    i += 1
  endwhile
  return listtotal
enddef # }}}
# Check and obtain header cells
def TblHeaderCells(tb: list<list<string>>): list<number> # {{{
enddef # }}}

def IsRowOrColumnData(data: string): string # {{{
  var kind = ''
  if data =~ '@\d*\$\d*\s*\.\.\s*@\d\$\d*'
    kind = 'rangecells'
  elseif data =~ '@\d*\$\d*'
    kind = 'cell'
  elseif data =~ '@\d*'
    kind = 'row'
  elseif data =~ '\$\d*'
    kind = 'column'
  else
    kind = 'not'
  endif
  return kind
enddef
# }}}

def FormulaRangesOrCells(formulas: list<string>): list<string> # {{{

  var listforms = []
  var straux = ''
  var lisaux = []
  for form in formulas
    lisaux = split(form, '=')
    straux = IsRowOrColumnData(lisaux[0])
    add(listforms, straux)
  endfor
  return listforms
enddef # }}}

def IsDataOrRange(st: string): string # {{{
  var kind = ''
  if st =~ '\$\d\s\.\s\$'
    kind = 'range'
  endif
  return kind
enddef
# }}}

def ObtainRowData(tb: list<list<string>>, column: number): list<string> # {{{
  var listdata = []
  if column > -1 || column < len(tb[column - 1])
    listdata = tb[column - 1]
  endif
  return listdata
enddef
# }}}
def ObtainColumnData(tb: list<list<string>>, column: number): list<string> # {{{
  var listdata = []
  var i = 0
  if column > -1 || column < len(tb)
    while i < len(tb)
      add(listdata, tb[column][i])
      i += 1
    endwhile
  endif
  return listdata
enddef
# }}}

def ObtainNumberDataRowsPipe(data: list<string>): list<number> # {{{
  var i = 0
  var exportdata = []
  while i < len(data)
    if data[i] == 'row'
      add(exportdata, i)
    endif
    i += 1
  endwhile
  return exportdata
enddef
# }}}

def ObtainSepsTbl(data: list<string>): list<number> # {{{
  var i = 0
  var topcell = 0
  var botcell = 0
  # 'tbl sep', 'tbl header'
  var listborders = []
  while i < len(data)
    if data[i] == 'tbl sep' || data[i] == 'tbl header'
      add(listborders, i)
    endif
    i += 1
  endwhile
  echo listborders
  return listborders
enddef
# }}}

def UseTopCellTbl(data: list<string>): list<number> # {{{
  var i = 0
  var listborders = ObtainSepsTbl(data)
  var listcells = []
  for rown in listborders
    if rown + 1 != len(data)
      add(listcells, rown + 1)
    endif
  endfor
  return listcells
enddef
# }}}

def SelectTblBCMcell(data: list<string>): list<number> # {{{
  var i = 0
  var celbeg = 0
  var celend = 0
  while i < len(data)
  endwhile
enddef
# }}}

def ObtainNumberDataRowsTbl(data: list<string>): list<number> # {{{
  var i = 0
  if g:org_tbl_cell_to_use = 'top'
  endif
enddef
# }}}
def ObtainRangeData(tb: list<list<string>>, info: list<number>): list<string> # {{{
  var listdata = []
  # info will include 4 values: [rowstart, columnstart, rowend, columnend]
  var i = info[0]
  var j = info[2]
  if (row > -1 && column > -1)
    while i < len(tb)
      j = column
      while j < len(tb[i])
        add(listdata, tb[i][j])
        j += 1
      endwhile
      i += 1
    endwhile
  endif
  return listdata
enddef
# }}}

def FormulaDetector(cell: string): string # {{{
  var formulas = ['exp', 'sin', 'tan', 'cos', 'vsum', 'vmean', 'vmax', 'vmin', 'vabs', 'vroot']
  if cell =~ '\a\('
    echo 'Cell has a formula'
  else
    echo 'Cell does not have a formula'
  endif
enddef
# }}}

def TableRowDescription(tbinfo: list<number>): list<string> # {{{
  var i = tbinfo[0]
  var j = 0
  var listdata = []
  var listlineswithdata = []
  var straux = ''
  while i < tbinfo[1]
    straux = IsTbOrFormula(i)
    add(listdata, straux)
    if straux == 'row'
      add(listlineswithdata, j)
    endif
    i += 1
    j += 1
  endwhile
  echo listlineswithdata
  return listdata
enddef # }}}

def DetectPipeRows(tb: list<list<string>>): list<number> # {{{
  var listcells = []
  var listseps = []
  var i = 0
  while i < len(tb)
    if tb[i][0] =~ '^\w' || tb[i][0] =~ '^\s*\w'
      add(listcells, i)
    elseif tb[i][0] = 
    endif
  endwhile
enddef
# }}}

# Creation of custom formulas {{{
def CalcMean(lst: list<string>): number # {{{
  var long = len(lst)
  var sum = 0
  var mean = 0
  for cell in lst
    sum += str2float(cell)
  endfor
  mean = sum/long
  return mean
enddef
# }}}
def CalcMedium(lst: list<string>): number # {{{
  var long = len(lst)
  var medval = 0
  var medium = 0.0
  var sortedvals = sort(lst)
  for cell in lst
    add(sortedvals, str2float(cell))
  endfor
  if (long / 2) * 2 < long
    medval = long / 2
    medium = sortedvals[medval]
  else
    medval = long / 2
    medium = (sortedvals[medval - 1] + sortedvals[medval]) / 2
  endif
  return medium
enddef
# }}}

def CalcMode(lst: list<string>): number
  var maxapp = ''
  var currap = 0
  var mode = ''
  var sortedvals = sort(lst)
enddef
#  }}}


export def SpreadSheetCalculateFormulas()
  var ln = line('.')
  var kind = IsTbOrFormula(ln)
  echo kind
  var tblist = CountTbandFormulas(ln)
  echo tblist
  var tabletype = IsTblOrPipe(tblist)
  echo tabletype
  var tb = []
  var formuls = []
  var kindformuls = []
  var coldesc = []
  var rowdesc = []
  var rowdatac = []
  var tblheads = []
  if kind != 'not'
    tb = SplitTbl(tblist)
    echo tb
    formuls = SplitFormulas(tblist)
    echo formuls
    kindformuls = FormulaRangesOrCells(formuls)
    echo kindformuls
    rowdesc = TableRowDescription(tblist)
    echo rowdesc
    rowdatac = ObtainNumberDataRowsPipe(rowdesc)
    echo rowdatac
    tblheads = UseTopCellTbl(rowdesc)
    # echo tblheads
    echo 'has a table'
  else
    echo 'nothing will happen'
  endif
enddef

#  }}}
