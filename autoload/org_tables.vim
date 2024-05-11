vim9script
# vim: set fdm=marker:
# vim: set nospell:
# Main string notes {{{
# Some parts to use strings, we can check the beginning or the end, or a
# specific range:
# let's suppose we have a string strexample = "Vim is awesome in 2024"
# if we echo strexample[:0], we will output the very first letter: 'V'.
# If we echo strexample[0:2] the output will be 'Vim'
# if we echo strexample[-4:-1] the output will be '2024'
#
# Main script notes to check:
#
# Functions prospected to create:
# Create org tables like pipe tables
# Create org tables like org_tbl with rows and headers
# }}}
export def OrgInsertTable() # Add a table {{{
  var line_number = line('.')
  var line_content = getline('.')
  append(line_number, "|   |   |")
  append(line_number, "|---|---|")
  append(line_number, "|   |   |")
  cursor(line_number + 1, 1)
  normal F|ll
  normal f|ll
  startinsert
enddef
# }}}
# Align the current table {{{

def OrgCutSpaces(st: string): string # Function to cut spaces {{{
  return trim(st)
enddef

#  }}}
export def IsColumnOrHeader(st: string): string # {{{
  var iscolorh = ''
  if (st[: 1] =~ '|\a') || (st[: 1] =~ '| ')
    iscolorh = 'column'
  elseif (st[: 2] =~ '+==') || (st[: 2] =~ '+--') || (st[: 2] =~ '+:=') || (st[: 2] =~ '+:-') ||
      (st[: 2] =~ '|:-') || (st[: 2] =~ '|--')
    iscolorh = 'header'
  else
    iscolorh = 'nottable'
  endif
  return iscolorh
enddef

#  }}}
def OrgTableLines(): list<number> # {{{
  var linen = line('.')
  var linec = getline(linen)
  var tbbeg = 0
  var tbend = 0
  var i = linen
  var whatis = ''
  while i > 0
    whatis = IsColumnOrHeader(getline(i))
    if whatis == 'column' || whatis == 'header'
      i -= 1
    elseif whatis == 'nottable'
      tbbeg = i + 1
      break
    endif
  endwhile
  i = linen
  while i > 0
    whatis = IsColumnOrHeader(getline(i))
    if whatis == 'column' || whatis == 'header'
      i += 1
    elseif whatis == 'nottable'
      tbend = i - 1
      break
    endif
  endwhile
  return [tbbeg, tbend]
enddef

#  }}}
def OrgSplitTable(lnnmb: number): list<string> # {{{
  var ln = getline(lnnmb)
  var whatis = IsColumnOrHeader(ln)
  var contentsplit = []
  if whatis == 'column'
    
  endif
enddef

#  }}}
def OrgSplitInCells(tbpos: list<number>): list<list<string>> # {{{
  var i = tbpos[0]
  var whatis = ''
  var listall: list<any>
  var listrow: list<any>
  while i <= tbpos[1]
    whatis = IsColumnOrHeader(getline(i))
    if whatis == 'column'
      listrow = split(getline(i), '|')
      add(listall, listrow)
      i += 1
    elseif whatis == 'header'
      listrow = split(getline(i), '+')
      add(listall, listrow)
      i += 1
    else
      break
    endif
  endwhile
  return listall
enddef

#  }}}
def OrgCleanSpaces(tb: list<list<string>>): list<list<string>> # {{{
  var i = 0
  var j = 0
  while i < len(tb)
    j = 0
    while j < len(tb[i])
      tb[i][j] = trim(tb[i][j])
      j += 1
    endwhile
    i += 1
  endwhile
  return tb
enddef

#  }}}
def OrgMaxlens(tb: list<list<string>>): list<number> # {{{
  var i = 0
  var j = 0
  var lens2calc = len(tb[0])
  var maxlens = []
  var maxlen = 0
  while i < len(tb[0])
    j = 0
    maxlen = 0
    while j < len(tb)
      if (strlen(tb[j][i]) > maxlen) && (tb[j][i][: 2] != '---') && (tb[j][i][: 2] != ':--') &&
         (tb[j][i][: 2] != '===') && (tb[j][i][: 2] != ':==')
        maxlen = strlen(tb[j][i])
      endif
      j += 1
    endwhile
    add(maxlens, maxlen)
    i += 1
  endwhile
  return maxlens
enddef

#  }}}
def OrgCheckTableType(tb: list<list<string>>): string # {{{
  var kindtable = ''
  var i = 0
  if tb[0][0] == '--' || tb[0][0] == ':-'
    kindtable = 'tbl'
  else
    kindtable = 'pipetable'
  endif
  return kindtable
enddef

#  }}}
def OrgCheckTableHeadliner(tb: list<list<string>>): number # {{{
  var i = 0
  var j = 0
  if tb[0][0][0] =~ '\w'
    i = 1
  else
    while i < len(tb)
      if tb[i][0][ : 1] =~ '==' || tb[i][0][ : 1] =~ ':='
        break
      elseif tb[i][0][-2 : ] =~ '-:' || tb[i][0][ : 1] =~ ':-'
        break
      else
        i += 1
      endif
    endwhile
  endif
  if i + 1 == len(tb)
    i = 0
  endif
  return i
enddef

#  }}}
def OrgCheckAligns(tb: list<list<string>>, tbtype: string, headline: number): list<string> # {{{
  var i = 0
  var j = 0
  var listaux = []
  if headline != 1
    j = headline
  else
    j = 1
  endif
  while i < len(tb[j])
    # Check Ragged left
    if (tb[j][i][ : 1] == '--' && tb[j][i][-2 : ] == '--') || (tb[j][i][ : 1] == ':-' && tb[j][i][-2 : ] == '--')
      add(listaux, 'left')
    # Check Ragged right
    elseif (tb[j][i][ : 1] == '--' && tb[j][i][-2 : ] == '-:')
      add(listaux, 'right')
    # Check center
    elseif (tb[j][i][ : 1] == ':-' && tb[j][i][-2 : ] == '-:')
      add(listaux, 'center')
    elseif (tb[j][i][ : 1] == '==' && tb[j][i][-2 : ] == '==') || (tb[j][i][ : 1] == ':=' && tb[j][i][-2 : ] == '==')
      add(listaux, 'left')
    # Check Ragged right
    elseif (tb[j][i][ : 1] == '==' && tb[j][i][-2 : ] == '=:')
      add(listaux, 'right')
    # Check center
    elseif (tb[j][i][ : 1] == ':=' && tb[j][i][-2 : ] == '=:')
      add(listaux, 'center')
    else
      add(listaux, 'left')
    endif
    i += 1
  endwhile
  return listaux
enddef

#  }}}
# Check if is aligned center, left or right {{{

def OrgAlignCellLeft(cell: string, sp: number): string # {{{
  var spacing = repeat(' ', sp)
  var auxlist = []
  if cell[: 1] == '--'
    spacing = repeat('-', sp + strlen(cell) + 2)
    auxlist = [spacing]
  elseif cell[: 1] == ':-'
    spacing = repeat('-', sp + strlen(cell) + 1)
    auxlist = [':', spacing]
  elseif cell[: 1] == '=='
    spacing = repeat('=', sp + strlen(cell))
    auxlist = [spacing]
  elseif cell[: 1] == ':='
    spacing = repeat('=', sp + strlen(cell) + 1)
    auxlist = [':', spacing]
  else
    auxlist = [' ', cell, spacing, ' ']
  endif
  var retstr = join(auxlist, '')
  return retstr
enddef

#  }}}
def OrgAlignCellRight(cell: string, sp: number): string # {{{
  var spacing = repeat(' ', sp)
  var auxlist = [' ', spacing, cell, ' ']
  if cell[-2 : ] == '-:'
    spacing = repeat('-', sp + strlen(cell) + 1)
    auxlist = [spacing, ':']
  elseif cell[-2 : ] == '--'
    spacing = repeat('-', sp + strlen(cell) + 2)
    auxlist = [spacing]
  elseif cell[-2 : ] == '=:'
    spacing = repeat('=', sp + strlen(cell) + 1)
    auxlist = [spacing, ':']
  endif
  var retstr = join(auxlist, '')
  return retstr
enddef

#  }}}
def OrgAlignCellCenter(cell: string, sp: number): string # {{{
  var i = sp / 2
  var spacing = ''
  var auxlist = []
  if cell[: 1] == '--' 
    spacing = repeat('-', sp + strlen(cell) + 2)
    auxlist = [spacing]
  elseif cell[: 1] == ':-'
    spacing = repeat('-', sp + strlen(cell))
    auxlist = [':', spacing, ':']
  elseif cell[: 1] == ':='
    spacing = repeat('=', sp + strlen(cell))
    auxlist = [':', spacing, ':']
  else
    if i * 2 < sp
      spacing = repeat(' ', i)
      auxlist = [' ', spacing, ' ', cell, spacing, ' ']
    else
      spacing = repeat(' ', i)
      auxlist = [' ', spacing, cell, spacing, ' ']
    endif
  endif
  var retstr = join(auxlist, '')
  return retstr
enddef

#  }}}
#  }}}
def OrgCellAligner(cell: string, talign: string, maxlen: number): string # {{{
  var newst = ''
  var sp = maxlen - strlen(cell)
  if talign == 'center'
    newst = OrgAlignCellCenter(cell, sp)
  elseif talign == 'right'
    newst = OrgAlignCellRight(cell, sp)
  elseif talign == 'left'
    newst = OrgAlignCellLeft(cell, sp)
  endif
  return newst
enddef

#  }}}
def OrgTableType(tbeg: number): string # {{{
  var typetable = ''
  if getline(tbeg) =~ '^\s*+--' || getline(tbeg) == '^\s*+:-'
    typetable = 'tbl.org'
  else
    typetable = 'pipetable'
  endif
  return typetable
enddef

#  }}}
def OrgSpaceCellInject(tb: list<list<string>>, lngth: list<number>, aligs: list<string>): list<list<string>> # {{{
  var i = 0
  var j = 0
  var diffsp = 0
  var sps = ''
  var lsaux = []
  # if tb[0][0][: 1] == '--' || tb[0][0][: 1] == ':-' 
  while i < len(tb)
    j = 0
    while j < len(tb[0])
      tb[i][j] = OrgCellAligner(tb[i][j], aligs[j], lngth[j])
      j += 1
    endwhile
    i += 1
  endwhile
  # endif
  return tb
enddef

#  }}}
def OrgTableConcatenator(tb: list<list<string>>): list<string> # {{{
  var i = 0
  var tblist = []
  var straux = ''
  while i < len(tb)
    if tb[i][0][: 1] == '--' || tb[i][0][: 1] == ':-' || tb[i][0][: 1] == '==' || tb[i][0][: 1] == ':='
        straux = '+' .. join(tb[i], '+') .. '+'
    else
      straux = '|' .. join(tb[i], '|') .. '|'
    endif
    add(tblist, straux)
    i += 1
  endwhile
  return tblist
enddef

#  }}}
def OrgReplaceAlignedTable(tb: list<string>, tblen: list<number>) # {{{
  deletebufline('%', tblen[0], tblen[1])
  var i = 0
  append(tblen[0] - 1, tb)
enddef

#  }}}
export def OrgAlignCells() # {{{
  # Check beginning and end of table
  var currpos = [ line('.'), col('.')  ]
  var orgtblimits = OrgTableLines()
  # echo orgtblimits
  # Split the whole table into separated elements
  var orgtbcontent = OrgSplitInCells(orgtblimits)
  # echo orgtbcontent
  # Clean spaces in all strings to take the true lenghts of strings
  orgtbcontent = OrgCleanSpaces(orgtbcontent)
  # echo orgtbcontent
  # Obtain maximum lenghts for each string, skipping headers or barriers
  var llens = OrgMaxlens(orgtbcontent)
  # echo llens
  # Obtain type of table, to check the headliner type for alignment purposes
  var tabletype = OrgTableType(orgtblimits[0])
  # echo tabletype
  # Obtain the headliner line to check how to align every cell
  var headtb = OrgCheckTableHeadliner(orgtbcontent)
  # echo headtb
  var aligns = OrgCheckAligns(orgtbcontent, 'lol', headtb)
  # echo aligns
  orgtbcontent = OrgSpaceCellInject(orgtbcontent, llens, aligns)
  # echo orgtbcontent
  var orgreptb = OrgTableConcatenator(orgtbcontent)
  OrgReplaceAlignedTable(orgreptb, orgtblimits)
  cursor(currpos)
enddef

#  }}}
#  }}}
# Add Row or header separators {{{

export def OrgAddRowSeparator()
  var linen = line('.')
  var linepc = ''
  var linenc = ''
  var auxstring = ''
  var auxlist = []
  var lenlist = []
  var finlist = []
  var pcis = 0
  if linen > 2
    linepc = getline(line('.') - 1)
    linenc = getline(line('.') + 1)
    pcis = 1
  else
    linepc = ''
    linenc = getline(line('.') + 1)
  endif
  var istable = 0
  if linepc =~ '^\s*|\a' || linepc =~ '^\s*|\s'
    # echo 'line is a part of a table'
    auxlist = split(linepc, '|')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
    # unlet cell
  elseif linepc =~ '^\s*+-*' || linepc =~ '^\s*+:-' || linepc =~ '^\s*+=*' || linepc =~ '^\s*+:='
    # echo 'line is a part of a table'
    auxlist = split(linepc, '+')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  elseif linenc =~ '^\s*|\a' || linenc =~ '^\s*|\s'
    auxlist = split(linenc, '|')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  elseif linenc =~ '^\s*+-*' || linenc =~ '^\s*+:-' || linenc =~ '^\s*+=*' || linenc =~ '^\s*+:='
    # echo 'line is a part of a table'
    auxlist = split(linenc, '+')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  else
    # echo 'Will use next line'
  endif
  # echo lenlist
  auxlist = []
  for cell in lenlist
    auxstring = repeat('-', cell)
    add(finlist, auxstring)
  endfor
  auxstring = '+' .. join(finlist, '+') .. '+'
  # echo auxstring
  append(linen, auxstring)
  # deletebufline('%', linen)
enddef

export def OrgAddRowHeader()
  var linen = line('.')
  var linepc = ''
  var linenc = ''
  var auxstring = ''
  var auxlist = []
  var lenlist = []
  var finlist = []
  var pcis = 0
  if linen > 2
    linepc = getline(line('.') - 1)
    linenc = getline(line('.') + 1)
    pcis = 1
  else
    linepc = ''
    linenc = getline(line('.') + 1)
  endif
  var istable = 0
  if linepc =~ '^\s*|\a' || linepc =~ '^\s*|\s'
    # echo 'line is a part of a table'
    auxlist = split(linepc, '|')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
    # unlet cell
  elseif linepc =~ '^\s*+-*' || linepc =~ '^\s*+:-' || linepc =~ '^\s*+=*' || linepc =~ '^\s*+:='
    # echo 'line is a part of a table'
    auxlist = split(linepc, '+')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  elseif linenc =~ '^\s*|\a' || linenc =~ '^\s*|\s'
    auxlist = split(linenc, '|')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  elseif linenc =~ '^\s*+-*' || linenc =~ '^\s*+:-' || linenc =~ '^\s*+=*' || linenc =~ '^\s*+:='
    # echo 'line is a part of a table'
    auxlist = split(linenc, '+')
    for cell in auxlist
      add(lenlist, strlen(cell))
    endfor
  else
    # echo 'Will use next line'
  endif
  # echo lenlist
  auxlist = []
  for cell in lenlist
    auxstring = repeat('=', cell)
    add(finlist, auxstring)
  endfor
  auxstring = '+' .. join(finlist, '+') .. '+'
  # echo auxstring
  append(linen, auxstring)
  # deletebufline('%', linen)
enddef
#  }}}
# Add a way to reach the values for rows or columns, detect  {{{

#  }}}
# Not currently used software parts {{{

#    while i < len(tb)
#      if tb[i][0] =~ '^=*$' || tb[i][0] =~ '^:=*$' || tb[i][0] =~ '^=*:$' || tb[i][0] =~ '^:=*:$'
#        headerbeg = i
#        echo 'Table has a header'
#        i = 0
#        break
#      else
#        i += 1
#      endif
#    endwhile
#    # i = 0
#    i = headerbeg + 1
#    if headerbeg >= 0
#      while i < len(tb)
#        if tb[i][0] =~ '^-*$' || tb[i][0] =~ '^:-*$' || tb[i][0] =~ '^-*:$' || tb[i][0] =~ '^:-*:$'
#          begrow = i
#          i += 1
#        elseif tb[i][0] =~ '^=*$' || tb[i][0] =~ '^:=*$' || tb[i][0] =~ '^=*:$' || tb[i][0] =~ '^:=*:$'
#          begrow = i
#          i += 1
#        elseif begrow == i - 1
#          cellrow = i
#          add(listv, tb[i])
#          i += 1
#        else
#          i += 1
#        endif
#      endwhile
#    endif
#  }}}
