vim9script
# vim: set fdm=marker:
# vim: set nospell:
# vim: set indentexpr=vimindent.Expr()

export def SemanticOrg(tkns: list<any>, tb: list<any> ): list<any>
  var tokens = tkns
  var i = 0
  var keys_list = GenerateListOfEls(tokens, 0)
  if count(keys_list, 'Keyword') < 0
    tokens = SolveFormulas(tokens)
  endif
enddef

export def SemanticFunction(tkns: list<any>, tb: list<any>): list<any> # {{{
  var tokens = tkns
  var tokens_added = [  ]
  var i = 0
  var len_tokens = len( tokens )
  var keys_list = GenerateListOfEls( tokens, 0 )
  if count( keys_list, 'Keyword' )
    tokens_added = SolveFormulas( tokens )
  endif
  if count( keys_list, 'Operator' )
    tokens_added = SolveMath( tokens_added )
  endif
  if count( keys_list, 'Concatenator' )
    tokens_added = SolveStrngs( tokens_added )
  endif
  return tokens_added
enddef #  }}}
def GenerateListOfEls(lst: list<any>, nmb: number): list<any> # {{{
  var list1 = []
  var el = ''
  var len_list = len(lst)
  var i = 0
  while i < len_list
    add( list1, lst[i][nmb] )
    i += 1
  endwhile
  return list1
enddef # }}}
# List Operation help {{{ 
# Adding and removing items from a list is done with functions.  Here are a few
# examples: >
# :call insert(list, 'a')  " prepend item 'a'
# :call insert(list, 'a', 3) " insert item 'a' before list[3]
# :call add(list, "new") " append String item
# :call add(list, [1, 2]) " append a List as one new item
# :call extend(list, [1, 2]) " extend the list with two more items
# :let i = remove(list, 3) " remove item 3
# :unlet list[3] " idem
# :let l = remove(list, 3, -1) " remove items 3 to last item
# :unlet list[3 : ] " idem
# :call filter(list, 'v:val !~ "x"')  " remove items with an 'x'
# }}}
def SolveFormulas(tkns: list<any>): list<any> # {{{
  var processed_tokens = tkns
  var result = []
  var list_els = GenerateListOfEls( tkns, 0 )
  var i = index( list_els, 'Keyword' ) # Very First formula element
  var j = 0
  while count( list_els, 'Keyword' ) > 0 || count( list_els, 'Error' ) > 0
    if tkns[i + 1][0] == 'LBracket'
      echo 'Excel Formula'
      j = index( list_els, 'RBracket', i )
      while count( list_els[ i + 1 : j - 1 ], 'Keyword' ) > 0
        i = index( list_els, i + 1 )
      endwhile
      result = SolveExcelFormula( processed_tokens[i : j] )
      insert( processed_tokens, result, j + 1 )
      remove( processed_tokens, i, j )
      list_els = GenerateListOfEls( processed_tokens, 0 )
    elseif tkns[i - 1][0] == 'LBracket' && tkns[ i - 2 ][0] == 'Squote'
      j = index( list_els, 'RBracket', i )
      while count(list_els[i : j], 'Squote') > 0 && count( list_els[i : j], 'LBracket' ) > 0
        i = index( list_els, i + 1 )
      endwhile
      result = SolveLispFormula( tkns[ i : j ] )
      processed_tokens = processed_tokens[ : i - 1 ] + result + processed_tokens[ j + 1 : ]
      list_els = GenerateListOfEls( processed_tokens, 0 )
    else
      return [ 'Error', 'ERR' ]
    endif
    if count( list_els, 'Keyword' ) == 0
      break
    endif
  endwhile
  return processed_tokens
enddef
# }}}
# Attend the necessity of add a formula verifier
# Excel Formula solving {{{
def SolveExcelFormula(tkns: list<any>): list<any> # {{{ 
  var result = []
  var verify_formula = ExcelFormulaVerifier(tkns[0])
  if verify_formula == 'math'
    return MathExcelSolver(tkns)
  elseif verify_formula == 'logic'
    return LogicExcelSolver(tkns)
  elseif verify_formula == 'string'
    return StringExcelSolver(tkns)
  else
    return [ 'Error', 'ERR' ]
  endif
  # return result
enddef # }}}
def ExcelFormulaVerifier(wrd: list<any>): string # {{{
  # Single variable statistics
  var list_math_formulas = [ 
    'vsum', 'vcount', 'vmax', 'vmean', 
    'vmeane', 'vhmean', 'vgmean', 
    'rms', 'vdiff', 'vmedian', 'vsdev', 'sin', 'cos', 'tan', 'asin', 'acos', 
    'atan', 'sec', 'csc', 'cot'
  ]
  var list_logic_formulas = [
    'if', 'and', 'or',
  ]
  var list_string_formulas = [
    'concat', 'trim'
  ]
  if index(list_math_formulas, wrd[1]) > -1
    return 'math'
  elseif index(list_logic_formulas, wrd[1]) > -1
    return 'logic'
  elseif index(list_string_formulas, wrd[1]) > -1
    return 'string'
  else
    return 'error'
  endif
    # '', '', '', '', '', '', '', '', '', '', 
    # '', '', '', '', '', '', '', '', '', '', '', '', '', 
    # '', '', '', '', '', '', '', '', '', '', '', '', '', 
enddef
# }}}
def MathExcelSolver(tkns: list<any>): list<any> # {{{ 
  var trigo_functions = [ 'sin', 'cos', 'tan', 'sec', 'csc', 'cot', 'asin' ]
  var statis_functions = [ 'vmean', 'vmedian', 'vmeane', 'vhmean', 'vgmean', ]
  var arit_functions = [ 'vsum', 'vmin', 'vmax' ]
  var constant = [ 'e', 'pi' ]
  if index( trigo_functions, tkns[0][1] ) > -1
    return MathExcelTrigoSolver( tkns )
  elseif index( statis_functions, tkns[ 0 ][1] ) > -1
    return MathExcelStatisSolver( tkns )
  # elseif index( arit_functions, tkns[ 0 ][1] ) > -1
  #   return MathExcelAritmSolver( tkns )
  else
    return [ 'Error', 'ERR' ]
  endif
enddef
# }}}
def MathExcelTrigoSolver(tkns: list<any>): list<any> # {{{ 
  var reslt = []
  var obtained = ''
  if tkns[0][1] == 'sin'
    obtained = trim( execute('echo sin(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'cos'
    obtained = trim( execute('echo cos(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'tan'
    obtained = trim( execute('echo tan(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'sec'
    obtained = trim( execute('echo 1 / cos(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'csc'
    obtained = trim( execute('echo 1 / sin(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'cot'
    obtained = trim( execute('echo 1 / tan(' .. tkns[2][1] .. ')' ))
  elseif tkns[0][1] == 'asin'
    obtained = trim( execute('echo asin(' .. tkns[2][1] .. ')' ))
  else
    return [ 'Error', 'ERR' ]
  endif
  return [ 'Float', obtained ]
enddef
# }}}
def MathExcelStatisSolver(tkns: list<any>): list<any> # {{{
  var reslt = []
  var obtained = ''
  if tkns[0][1] == 'vsum'
  elseif tkns[0][1] == 'vmedian'
  elseif tkns[0][1] == 'vmeane' 
  # elseif tkns[0][1] 'vhmean'
  elseif tkns[0][1] == 'vgmean'
  endif
  return reslt
enddef
#  }}}
def MathExcelAritmSolver(tkns: list<any>): list<any> # {{{
  var obtained = ''
  if tkns[0][1] == 'vmean'
    obtained = SolveMean( tkns[1 : -2 )

  endif
  return [ 'Float', obtained ]
enddef
#  }}}
# }}}
# Math Formulas {{{

def SolveMean(tkns: list<any>): list<any> # {{{
  var result_list = [ 'Float', '' ]
  return result_list
  var sum = 0.0
  var i = 0
  var lin = len(tkns)
  while i < len(lin)
    sum += float(tkns[i][1])
    i += 1
  endwhile
  return [ 'Float', string(sum) ]
enddef
#  }}}
def SolveMedian(tkns: list<any>): list<any> # {{{
  var meanlist = [ 'Float', '' ]
  return meanlist
enddef
#  }}}
def SolveMeanError(tkns: list<any>): list<any> # {{{
  var meanlist = [ 'Float', '' ]
  return meanlist
enddef
#  }}}
def SolveGeometricMean(tkns: list<any>): list<any> # {{{
  var meanlist = [ 'Float', '' ]
  return meanlist
enddef
#  }}}
#  }}}
def LogicExcelSolver(tkns: list<any>): list<any> # {{{
  var  = 
  if tkns[0][1] == 'if'
    return SolveIf(tkns)
  elseif tkns[0][1] == 'and'
    return SolveAnd(tkns)
  elseif tkns[0][1] == 'or'
    return SolveOr(tkns)
  else 
    return []
  endif
enddef
#  }}}
def SolveIf(tkns: list<any>): list<any>
  return []
enddef
def StringExcelSolver(tkns: list<any>): list<any> # {{{
  return []
enddef
#  }}}
def SolveMath(tkns: list<any>): list<any> # {{{
  var processed_tokens = []
  return processed_tokens
enddef
#  }}}
def SolveStrngs(tkns: list<any>): list<any> # {{{
  var processed_tokens = []
  return processed_tokens
enddef
#  }}}

#  }}}
# Solve for Lisp Formulas {{{

def SolveLispFormula(tkns: list<any>): list<any> # {{{
  return []
enddef
#  }}}
# Cell data extractor {{{

def ExtractCell(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def ExtractCellRng(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def ExtractCurrColRng(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def ExtractCurrColCll(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def ExtractCurrRowCll(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def ExtractCurrRowRng(tb: list<any>, cll: string): list<any> # {{{
  var extracted_list = []
  return extracted_list
enddef

def TableDataArrange(dta: string): string # {{{
  var modifydta = dta
  var modifieddta = ''
  if modifydta =~ '^\s*\$\s\d*\.\d*\s*$'
    modifieddta = CurrencyDta( modifydta )
  elseif modifydta =~ '\d*\.\d*'
  endif
  return modifieddta
enddef
#  }}}
