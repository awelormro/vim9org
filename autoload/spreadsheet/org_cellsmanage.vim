vim9script
# vim: set fdm=marker:
# vim: set nospell:
# /home/abu/Plantillas/vim9org/autoload/spreadsheet/extractdata.vim
import autoload "spreadsheet/org_formulas.vim" as frml
import autoload "spreadsheet/extractdata.vim" as exct
# sitio para checkar tonos:
# #334422
#

export def CountRangesNested(frmla: string): list<any> # {{{
  # Count and separate the nested formulas, can only split the values in a
  # list, or a dictionary with nested functions, separating all the arguments
  var opn_bracks_list = []
  var count_opn_bracks_quotes = []
  var dict_exit = []
  var all_close_pars = Stridxlist( frmla, ')' )
  var all_open_pars = Stridxlist( frmla, '(' )
  var nested_formulas = {}
  var adict = { 
    'key1': [], 
    'keyadd': {  }
  }
  var bdict = {'key2': [1, 2, 3] }
  extend( adict['keyadd'], bdict )
  extend( nested_formulas, bdict )
  echo adict
  echo nested_formulas
  echo all_open_pars
  echo all_close_pars
  return []
enddef # }}}
# Roadmap: {{{
# 1.- Obtain the data information, row and col for complete the function:
#     ObtainStart
# 2. - Read formula: ObtainStart also generates the isolated formula
# 3. - Extract ranges with functions
# 4. - If has:
#   4.1.- Obtain the data information, row and col for complete the function
#         ObtainStart do that part
#   4.2.- Count every formula, fill list with included functions: ReadFunctions
#   4.3.- Check start and end, fill list with lists by any appearance in order
#         of every included function: ReadNumberOfFunctions with
#         GetFormulaValsinLists do the job
#   4.4.- Check valid Ranges in all of them, if not, directly throw error in
#         formula, ObtainStringFunctions will create the lists for the
#         formulas, ValuesInFunc will obtain the values for a function,
#         ValuesInAllFunc will create the list of every range
#   4.5.- If yes, extract the ranges and kind With the values obtained in
#         ValuesInFuncs will start a function to extract all the ranges in
#         every formula, RangesOfInfo will lead the obtaining of every kind of
#         formula, will be helped of ObtainData, will trigger if needed the
#         other function, called ExtractDataFromTable to generate the list of
#         every single data range
#   4.6.- With ranges and kind, obtain data from table, and generate list of
#     lists with all data inside, a list for every range
#   4.7.- With data of every range, run loop for every obtained range following
#     the direct length and create two lists, one with the formula previous to
#     substitute, and another with the obtained value
#   4.8.- Substitute in the original string from top to bottom for every formula
# 5.- Substitute the ranges for cells, if has ranges in this point, return ERR
# 6.- If the values are numeric, finish the operations, if is only text and has
#   operators, return ERR
# 7.- Substitute value in the table with the obtained value
# }}}
# Final function
export def ObtainStart(frmla: string): list<any> # {{{
  # InputEx1: @3$4=vmean($4..$6)
  # OutputEx1: [3,4, vmean($4..$6)]
  # Status: Passed
  # InputEx2: B4=vmean(C1..C3)
  # OutputEx2: []
  var list_start = []
  var start_formula = stridx( frmla, '=' )
  # echo start_formula
  var straux = split(  frmla[ 1 : stridx( frmla, '=' ) - 1 ], '\$' )
  for part in straux
    add( list_start, str2nr( part ) )
  endfor
  add( list_start, frmla[ start_formula + 1 : ] )
  return list_start
enddef
# }}}
export def Stridxlist(strng: string, ocurr: string): list<number> # {{{
  # Obtain: List of all start positions by given ocurr
  # Test: Passed
  var listdef = []
  var i = 0
  while i > -1
    if stridx( strng, ocurr, i ) > -1
      add( listdef, stridx( strng, ocurr, i ) )
      i = stridx( strng, ocurr, i ) + 1
    else
      break
    endif
  endwhile
  return listdef
enddef
# }}}

export def ExtractDataFromTable(tb: list<any>, dta: string, cll: list<any>): list<any> # {{{
  var ranges_to_search_data = [   # {{{
    'RangeCells',
    'Cell',      
    'RangeRows', 
    'RangeCols', 
    'CurrRow',   
    'CurrCol',   
  ] # }}}
  var symbols_to_use = [ '@', '\.\.', '\$' ]
  var i = 0
  var j = 0
  var end1 = 0
  var end2 = 0
  # echo cll
  var list_split_range = []
  var list_dta = []
  var case_range = index( ranges_to_search_data, CheckKindOfDataRange( dta ) )
  # echo case_range
  # 'RangeCells' {{{ 
  if case_range == 0
    # echo 'Cell range'
    # echo dta
    list_split_range = split( dta, symbols_to_use[1] )
    # echo list_split_range
    # echo list_split_range
    list_split_range[0] = split( list_split_range[0][ 1 : ], symbols_to_use[2] )
    list_split_range[1] = split( list_split_range[1][ 1 : ], symbols_to_use[2] )
    list_split_range = list_split_range[0] + list_split_range[1]
    i = str2nr( list_split_range[0] ) - 1
    j = str2nr( list_split_range[1] ) - 1
    while i < len( tb ) && i < str2nr( list_split_range[2] )
      j = str2nr( list_split_range[1] ) - 1
      while j < len( tb[0] ) && i < str2nr( list_split_range[3] )
        add( list_dta, tb[i][j] )
        j += 1
      endwhile
      i += 1
    endwhile
    # echo list_dta
    return list_dta
  # }}}
  # 'Cell', {{{ 
  elseif case_range == 1
    # echo cll
    return [ tb[ cll[0] - 1 ][ cll[1] - 1 ] ]
  # }}}
  # 'RangeRows', {{{ 
  elseif case_range == 2
    # '@\d*\.\.@\d*$'
    list_split_range = split( dta, symbols_to_use[1] )
    i = 0
    while i < len( list_split_range )
      list_split_range[i] = str2nr( list_split_range[i][1 : ] ) - 1
      i += 1
    endwhile
    i = list_split_range[0]
    while i < list_split_range[1] && i < len( tb[0] )
      add( list_dta, tb[i][cll[1] - 1] )
      i += 1
    endwhile
    # echo list_split_range
    return list_dta
  # }}}
  # 'RangeCols', {{{
  elseif case_range == 3
    list_split_range = split( dta, symbols_to_use[1] )
    i = 0
    while i < len( list_split_range )
      list_split_range[i] = str2nr( list_split_range[i][1 : ] ) - 1
      i += 1
    endwhile
    i = list_split_range[0]
    while i < list_split_range[1] && i < len( tb )
      add( list_dta, tb[cll[1] - 1][i] )
      i += 1
    endwhile
    # echo list_split_range
    # echo list_dta
    return list_dta
  # }}}
  elseif case_range == 4
    # 'CurrRow',   {{{
    # i =str2nr(  )
    # echo tb[ cll[0] - 1 ][ str2nr( dta[1 : ] ) - 1 ]
    return [ tb[ cll[0] - 1 ][ str2nr( dta[1 : ] ) - 1 ] ]
    # return []
    # }}}
  elseif case_range == 5
    # 'CurrCol', {{{
    # echo tb[ cll[0] - 1 ][ str2nr( dta[1 : ] ) - 1 ]
    return [ tb[ str2nr( dta[1 : ] ) - 1 ][ cll[1] - 1 ] ]
    # }}}
  else
    return []
  endif
enddef # }}}

export def GenerateValues(dta: list<any>, frmla: string): string # {{{
    var listed_vals = g:org_sp_formula_list
    var case_exec = index( g:org_sp_formula_list, frmla )
    # 'vsum', 'vmean', 'vmax', 'vmin', 'vmedian', 'vconcat'
    echo case_exec
    if case_exec == 0 # vsum
      return frml.VsumCalc(dta) 
    elseif case_exec == 1 # vmean
      return frml.VmeanCalc(dta)
    elseif case_exec == 2 # vmax
      return frml.VmaxCalc(dta)
    elseif case_exec == 3 # vmin
      return frml.VminCalc(dta)
    elseif case_exec == 4 # vmedian
      return frml.VmedianCalc(dta)
    elseif case_exec == 5 # vconcat
      return frml.VconcatMake(dta)
    else 
      return 'ERR'
    endif
enddef # }}}
def GetFormulaValsinLists(frmla: string, frmla2find: string): list<any> # {{{
  # InputEx1: 
  # frmla = 'vmean(@2$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)'
  # frmla2find = 'vmean'
  # OutputEx1: [[0,10]]
  var list_pos_func = []
  var start_points = Stridxlist( frmla, frmla2find )
  for start_point in start_points
    add( list_pos_func, [ start_point, -10 ] )
  endfor
  # echo list_pos_func
  var i = 0
  for val_list in list_pos_func
    i = val_list[0]
    val_list[1] = stridx( frmla, ')', i + 1 )
  endfor
  # echo list_pos_func
  return list_pos_func
enddef
# }}}
export def DictGen(): dict<any>
  var dictionary_functions = { # {{{
  'vsum': { 
    'in_function': 0,
    'origins':       [],
    'ends':          [],
    'listed_vals':   [],
    'splitted_vals': [],
    'obtained_vals': [],
    'calculated':    []
  }, 
  'vmean': { 
    'in_function': 0,
    'origins': [],
    'ends': [],
    'listed_vals': [],
    'splitted_vals': [],
    'obtained_vals': []
  }, 
  'vmax': { 
    'in_function': 0,
    'origins': [],
    'ends': [],
    'listed_vals': [],
    'splitted_vals': [],
    'obtained_vals': []
  }, 
  'vmin': { 
    'in_function': 0,
    'origins': [],
    'ends': [],
    'listed_vals': [],
    'splitted_vals': [],
    'obtained_vals': []
  }, 
  'vmedian': { 
    'in_function': 0,
    'origins': [],
    'ends': [],
    'listed_vals': [],
    'splitted_vals': [],
    'obtained_vals': []
  }, 
  'vconcat': { 
    'in_function': 0,
    'origins': [],
    'ends': [],
    'listed_vals': [],
        'splitted_vals': [],
        'obtained_vals': []
      }, 
} # }}}
      return dictionary_functions
enddef 
export def RangeCells(dict: any, frmla: string, tb: list<any>, cll: list<any>): dict<any> # {{{ 
  var list_endings = []
  var auxlist = []
  var list_all = []
  var i = 0
  for elem in keys( dict ) 
    auxlist = []
    i = 0
    dict[elem]['origins'] = GetFormulaValsinLists( frmla, elem )
    for orig in dict[elem]['origins']
      # echo frmla[ orig[0] : orig[1] ]
      add( dict[elem]['listed_vals'], frmla[ orig[0] + strlen(elem) + 1 : orig[1] - 1 ] )
    endfor
    # echo dict[elem]['listed_vals']
    for l in dict[elem]['listed_vals']
      add( auxlist, l )
    endfor
    while i < len( auxlist )
      if auxlist[i] =~ ',,,'
        auxlist[i] = substitute( auxlist[i], ',,,', ',' .. g:org_sp_formula_sep .. ',', '' )
      endif
      i += 1
    endwhile
    # echo auxlist
    for l in auxlist
      add( dict[elem]['splitted_vals'], split(l, ',') )
    endfor
    auxlist = []
    echo dict[elem]['splitted_vals']
    for l in dict[elem]['splitted_vals']
      auxlist = []
      echo l
      for lst in l
        auxlist = ExtractDataFromTable( tb, lst, ObtainStart( cll[-1] ) )
        list_all = list_all + auxlist
      endfor
      # echo list_all
      add( dict[elem]['obtained_vals'], list_all )
    endfor
    list_all = []
    auxlist = []
    for l in dict[elem]['obtained_vals']
      # echo elem
      # echo l
      echo GenerateValues( l, elem )
    endfor
  endfor
  return dict
enddef # }}}
