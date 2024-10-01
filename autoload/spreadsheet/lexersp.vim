vim9script
# vim: set foldmethod=marker:
export def LexerSp(frmla: string): list<any>
  var i = 0
  var token = []
  var tokeninfo = []
  var tokens = []
  var start = 0
  var end = 0
  var operators = [ '+', '-', '*', '/', '^' ]
  var separators = [',', '=' ]
  var bracketsl = [ ')', '(' ]
  var lfrmla = len( frmla )
  while i < lfrmla
    if index( operators, frmla[i] ) > -1
      tokeninfo = AddOperatorToken( frmla[i], i )
    elseif index( separators, frmla[i] ) > -1
      tokeninfo = AddSeparatorToken( frmla[i], i )
    elseif index( bracketsl, frmla[i] ) > -1
      tokeninfo = AddBracketToken( frmla[i], i )
    elseif frmla[i] == "'"
      tokeninfo = AddSquoteToken( frmla[i], i )
    elseif frmla[i] == '"'
      tokeninfo = AddStringToken( frmla, i )
    elseif frmla[i] =~ '\l'
      tokeninfo = AddKWordToken( frmla, i )
    elseif frmla[i] =~ '@'
      tokeninfo = CellAtToken( frmla, i )
    elseif frmla[i] =~ '\$'
      tokeninfo = CellDllToken( frmla, i )
    elseif frmla[i] =~ '\d'
      tokeninfo = NumberToken( frmla, i )
    elseif frmla[i] =~ '\u'
      tokeninfo = ExcelToken( frmla, i )
    elseif frmla[i] =~ '\s'
      tokeninfo = SpaceToken( frmla, i )
    else
      tokeninfo = [ i + 1, [ 'Non spec', frmla[i] ] ]
    endif
    add( tokens, tokeninfo[1] )
    i = tokeninfo[0]
  endwhile
  return tokens
enddef

def AddBracketToken(dta: string, i: number): list<any>
  var token = [  ]
  var retoken = []
  if dta == '('
    token = [ 'LBracket', dta ]
    retoken =  [ i + 1, token ]
  elseif dta == ')'
    token = [ 'RBracket', dta ]
    retoken = [ i + 1, token ]
  endif
  return retoken
enddef

def AddOperatorToken(dta: string, i: number): list<any>
  var token = [ 'Operator', dta ]
  return [ i + 1, token ]
enddef

def AddSeparatorToken( dta: string, i: number ): list<any>
  var token = [ 'Separator', dta ]
  return [ i + 1, token ]
enddef

def AddSquoteToken(dta: string, i: number): list<any>
  var token = [ 'Squote', dta ]
  return [ i + 1, token ]
enddef

def AddStringToken(dta: string, i: number): list<any>
  var start = i
  var end = stridx( dta, '"', i + 1 )
  var token = [ 'String', dta[ start : end ] ]
  return [ end + 1, token ]
enddef

def AddKWordToken(dta: string, i: number): list<any>
  var start = i
  var end = i
  var k = i
  k += 1
  while dta[k] =~ '\a' && k < len( dta )
    end += 1
    k += 1
  endwhile
  var token = [ 'Keyword', dta[ start : end ] ]
  return [ end + 1, token ]
enddef

def CellAtToken(dta: string, i: number): list<any>
  var start = i
  var vend = i
  var cnt_dots = 0
  var cnt_at = 1
  var cnt_dllr = 0
  var dllr1 = 0
  var dllr2 = 0
  var at1 = dta[i]
  var at2 = 0
  var brker = 0
  var k = i
  var err_token = 0
  var token = []
  k += 1
  while k < len( dta ) && cnt_dots < 2 && cnt_at < 3 && cnt_dllr < 3 && err_token == 0 && brker < 1
    if dta[k] =~ '\d'
      vend = k
      k += 1
    elseif dta[k] == '$'
      cnt_dllr += 1
      vend = k
      k += 1
    elseif dta[k] == '.'
      if dta[k + 1] == '.'
        cnt_dots = 1
        vend = k + 1
        k += 2
      else
        err_token = 1
        vend = k
      endif
    elseif dta[k] == '@'
      cnt_at += 1
      vend = k
      k += 1
    else
      brker = 1
      break
    endif
  endwhile
  token = SelectAtToken( dta, cnt_dots, cnt_at, cnt_dllr, start, vend, err_token )
  return [ vend + 1, token ]
enddef

def SelectAtToken( dta: string, cnt_dots: number, cnt_at: number, cnt_dllr: number, strt: number, vend: number, errflg: number ): list<any>
  if cnt_dots == 0 && cnt_at == 1 && cnt_dllr == 1
    return [ 'Cell', dta[ strt : vend ] ] # Passed
  elseif cnt_dots == 1 && cnt_at == 2 && cnt_dllr == 2
    return [ 'Cell Range', dta[ strt : vend ] ] # Passed
  elseif cnt_dots == 1 && cnt_at == 2 && cnt_dllr == 0
    return [ 'CurrCol Cell Range', dta[ strt : vend ] ] # Passed
  elseif cnt_dots == 0 && cnt_at == 1 && cnt_dllr == 0
    return [ 'CurrCol Cell', dta[ strt : vend ] ] # Passed
  elseif errflg > 0
    return [ 'Error', 'ERR' ]
  else
    return [ 'Error', 'ERR' ]
  endif
enddef

def CellDllToken( dta: string, k: number ): list<any>
  var start = k
  var vend = k
  var cnt_dots = 0
  var cnt_spcs = 0
  var cnt_dllr = 1
  var dllr1 = dta[k]
  var dllr2 = 0
  var brker = 0
  var i = k
  var err_token = 0
  var token = []
  i += 1
  while i < len( dta ) && cnt_dots < 3 && cnt_dllr < 3 && err_token == 0 && brker < 1 && cnt_spcs < 2
    if dta[i] == '$'
      cnt_dllr = 2
      vend = i
      i += 1
    elseif dta[i] == ' '
      cnt_spcs = 1
      vend = i
      i += 1
    elseif dta[i] =~ '\d'
      vend = i
      i += 1
    elseif dta[i] == '.'
      cnt_dots += 1
      vend = i
      i += 1
    else
      break
    endif
  endwhile
  token = DllrToken( dta, cnt_dots, cnt_dllr, cnt_spcs, start, vend, err_token )
  return [ vend + 1, token ]
enddef

def DllrToken(dta: string, cnt_dots: number, cnt_dllr: number, cnt_spcs: number, strt: number, vend: number, errflg: number): list<any>
  if cnt_dots == 1 && cnt_dllr == 1 && cnt_spcs == 1
    return [ 'Currency', dta[ strt + 2 : vend ] ] # Passed
  elseif cnt_dots == 0 && cnt_spcs == 0 && cnt_dllr == 1
    return [ 'CurrRow Cell Token', dta[ strt : vend ] ] # Passed
  elseif cnt_dots == 2 && cnt_spcs == 0 && cnt_dllr == 2 
    return [ 'CurrRow Cell Range', dta[ strt : vend ] ] # Passed
  elseif errflg > 0
    return [ 'Error', 'ERR' ]
  else
    return [ 'Error', 'ERR' ]
  endif
enddef

def NumberToken(dta: string, k: number ): list<any>
  var i = k
  var cnt_dots = 0
  var start = k
  var vend = k
  var brk = 0
  var token = []
  while i < len( dta ) && cnt_dots < 2 && brk < 1
    if dta[i] =~ '\d'
      vend = i
      i += 1
    elseif dta[i] == '.'
      cnt_dots += 1
      vend = i
      i += 1
    else
      break
    endif
  endwhile
  if cnt_dots > 0
    token = [ "Float", dta[ start : vend ] ]
    return [ vend + 1, token ]
  else
    token = [ "Int", dta[ start : vend ] ]
    return [ vend + 1, token ]
  endif
enddef

def ExcelToken(dta: string, k: number ): list<any>
  var i = k
  var cnt_dots = 0
  var cnt_caps = 0
  var cnt_ands = 0
  var start = k
  var vend = k
  var brk = 0
  var charst = "&"
  var token = []
  while i < len( dta ) && cnt_dots < 2 && brk < 1 && cnt_caps < 3 && cnt_ands < 3
    if dta[i] =~ '\u'
      vend = i
      cnt_caps += 1
      i += 1
    elseif dta[i] == ':'
      vend = i
      cnt_dots += 1
      i += 1
    elseif dta[i] == '&'
      vend = i
      cnt_ands += 1
      i += 1
    elseif dta[i] =~ '\d'
      vend = i
      i += 1
    else
      break
    endif
  endwhile
  if cnt_dots < 1
    token = [ 'ExcelCell', dta[start : vend] ]
    return [ vend + 1, token ]
  else
    token = [ 'ExcelRange', dta[start : vend] ]
    return [ vend + 1, token ]
  endif
enddef

def SpaceToken(dta: string, i: number): list<any>
  return [ i + 1, [ 'Space', ' ' ] ]
enddef
