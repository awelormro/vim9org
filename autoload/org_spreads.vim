vim9script
# vim: set fdm=marker:
# vim: set nospell:
import autoload "org_tables.vim" as tbl
import autoload "orglibs/comparissions.vim" as cmp
# After checking docs, spreadsheet features are not allowed into orgtbl. Only
# to add it to the table, will check for the top lines in case of orgtbl
# tables, will check the very first value of every kind.
# Another important feature will be the check for advanced calculations and
# recognizing cells and names, will be added to the todo
# Main function to calculate the formulas
export def OrgObtainSpreadData() # {{{
  # Roadmap for the plugin {{{
  # cellsobtained will contain the lines in the main matrix with elements that
  # are data, depending on the row element, with this, we can select only
  # values that 
  # If tables begin and end exists,  {{{
  # - obtain the type of table X
  # - obtain the kind of line for every row X
  # - Split the table into individual cells X
  # With the type of table, check if is pipe table:
  # - just add valid values that
  # - are not the kind 
  # If is a Tbl.org table:
  # - Check the variable for heading 
  # }}}
  # }}}
  # Variable declarations {{{
  # First: Obtain the table data
  # Kind of table parts 
  var table_parts = ['pipe separator', 'row', 'tbl header', 'tbl separator', 'formula line', 'none']
  # Kind of headings
  var table_type_header = ['center', 'left', 'right']
  var table_kinds = ['tbl', 'pipe']
  var splitted_table = []
  # curpos: [0, lnum, col, off, curswant]
  var curpos = getcurpos()
  # tbl_parts [table_begin, table_end, formulas_begin, formulas_end]
  var tbl_parts = [-10, -10, -10, -10]
  # Use as a flag for detect if is a table, formula or not a table part
  var is_table = ''
  # Obtain Line content in the current moment
  var linec = getline(curpos[1])
  # variables to use as an index for loops
  var i = 0
  var j = 0
  var k = 0
  # }}}
  # Check if the line is a table part, formula line or not a line table {{{
  i = curpos[1]
  var list_tbl_elements = []
  var list_tbl_formulas = []
  is_table = cmp.Partlist(getline(line('.')))
  # }}}
  # Check lines of table begin, table end, and the existance of formulas line {{{
  if index(table_parts, is_table) < 4 && index(table_parts, is_table) > -1
    # Logic on this section {{{
    # Must Count up to obtin the table begin
    # Must Count down to obtain the table end
    # Must add 1 to table end and check if the formula line exists
    # If exists formula,
    # - check formulas_begin and 
    # - then count down to formulas_end
    # Create list of [table_begin, table_end, formulas_begin, formulas_end]
    # }}}
    # echo 'Is a table part'
    tbl_parts[0] = cmp.CountLinesUp1(i, ['pipe separator', 'row', 'tbl header', 'tbl separator'])
    tbl_parts[1] = cmp.CountLinesDown(i, ['pipe separator', 'row', 'tbl header', 'tbl separator'])
    tbl_parts[2] = cmp.CountLinesUp1(tbl_parts[1] + 1, ['formula line'])
    tbl_parts[3] = cmp.CountLinesDown(tbl_parts[2], ['formula line'])
    list_tbl_elements = cmp.KindsList([tbl_parts[0], tbl_parts[1]])
  elseif index(table_parts, is_table) == 4
    # Logic on this section {{{
    # Must Count up to obtain the formula begin
    # Must Count down to obtain the formula end
    # Must substract 1 to table end and check if the formula line exists
    # If exists formula,
    # - check table_begin and 
    # - then count down to table_end
    # Create list of [table_begin, table_end, formulas_begin, formulas_end]
    # }}}
    echo 'Is a Formula part'
    tbl_parts[2] = cmp.CountLinesUp1(i, ['formula line'])
    tbl_parts[3] = cmp.CountLinesDown(i, ['formula line'])
    tbl_parts[0] = cmp.CountLinesUp1(tbl_parts[2] - 1, ['pipe separator', 'row', 'tbl header', 'tbl separator'])
    tbl_parts[1] = cmp.CountLinesDown(tbl_parts[0], ['pipe separator', 'row', 'tbl header', 'tbl separator'])
    list_tbl_elements = cmp.KindsList([tbl_parts[0], tbl_parts[1]])
  else
    # Don't do anything {{{
    # Edit and don't add anything
    # add a flag of non existent formula or table
    # }}}
    echo 'Is nothing'
  endif
  # echo tbl_parts
  # echo list_tbl_elements
  # }}}
  var table_types = ''
  # If the table lines exists, Split the lines and obtain table type {{{
  if tbl_parts[0] > 0
    table_types = cmp.TableType(tbl_parts)
    splitted_table = cmp.SplitTable(tbl_parts)
  else
    table_types = 'none'
  endif
  # echo table_types
  # echo splitted_table
  # }}}
  # If the formula lines exists, obtain the formulas in formulas table {{{
  if tbl_parts[2] > 0
    list_tbl_formulas = cmp.FormulasSplit1(tbl_parts)
  endif
  # echo list_tbl_formulas
  # }}}
  # Obtain the aviable row cells  number with data {{{
  var cellsobtained = cmp.ObtainTableData(list_tbl_elements, table_types)
  # echo cellsobtained
  # }}}
  # With the obtained aviable data rows, obtain the places for formula lines {{{
  var list_formulas_in_tbl = cmp.ObtainFormulaLines(splitted_table, cellsobtained)
  # echo list_formulas_in_tbl
  # }}}
  # After, obtain the matrix of elements that will be aviale for formulas and trasposed {{{
  var matrixcells = cmp.GenerateCellMatrix(splitted_table, cellsobtained)
  # echo matrixcells
  var transpmatrix = cmp.TransposeTable(matrixcells)
  # echo transpmatrix
  # }}}
  # Obtain the formulas inside table and add it to the list of formulas {{{
  var list_table_formulas = cmp.GetFormulasInsideTable(splitted_table, cellsobtained)
  # echo list_table_formulas
  list_tbl_formulas += list_table_formulas
  # echo list_tbl_formulas
  # }}}
  # With the formula lines, will create a matrix with table kinds of data {{{
  var list_tbl_kinds = cmp.GenerateDataTypeMatrix(matrixcells)
  # echo list_tbl_kinds
  # }}}
  # Obtain the maximum number in index in line {{{
  var listrowkinds = cmp.ListOfElementsInRows(list_tbl_kinds)
  # echo listrowkinds
  # }}}
  # Check the formulas and check if there are column, cell or range formulas {{{
  var types_formulas = cmp.CheckAllFormulaTypes(list_tbl_formulas)
  # echo types_formulas
  var prototype_row_formula = cmp.GenerateRowFormulas(matrixcells, list_tbl_kinds, '@3=vsum($2..$5)')
  # echo prototype_row_formula
  var prototype_col_formula = cmp.GenerateColFormulas(matrixcells, list_tbl_kinds, '$3=vsum($2..$5)')
  # echo prototype_col_formula
  cmp.ChangeCellCols()
  # }}}
enddef
# }}}

