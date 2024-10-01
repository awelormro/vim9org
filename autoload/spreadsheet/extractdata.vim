vim9script

export def LexacOrgFm(frmla: string): list<any>
  var tokens = []
  var i = 0
  var j = 0
  var auxend = 0
  var start = 0
  var  = 
  var symbol_dictionary = { 
    'operators': [ '+', '-', '*', '/', '^' ],
    'structels': [ "'", '(', ')' ],
    'frmlas':    [ 'vmax', 'vmin', 'vaverage', 'vsum', 'vconcat' ],
    'lispfrmlas': [ 'concat', 'mapconcat', 'identity', 'delete-dups', 'list' ]
  }
  while i < len(frmla)
    if index( symbol_dictionary['operators'], frmla[i] ) > -1
      add( tokens, [ 'operator', frmla[i] ] )
      i += 1
    elseif index( symbol_dictionary['structels'], frmla[i] ) > -1
      add( tokens, [ 'structel', frmla[i] ] )
      i += 1
    elseif frmla[i] == '"'
      auxend = stridx( frmla, '"', i + 1 )
      add( tokens, [ 'string', frmla[ i : auxend ] ] )
      i = auxend + 1
    else
      j = i + 1
      while j < len( frmla )
        if 1 == 1 # Case integers
        elseif 2 == 2 # Case money
        endif
      endwhile
    endif
  endwhile
  return tokens
enddef

export def NumericValThreat(frmla: string, cpos: number): list<any>
  
enddef

def MainkWsep(frmla: string): string
  var kword = ''
  return kword
enddef

export def RangeFromTb(tb: list<any>, rng: string, cll: list<any>): list<any>
  var list_ranges = []
  var i = 0
  var j = 0
  var delims = []
  if rng =~ '@\d*\$\d*$'
    delims = split( rng[1 : ], '\$' )
    delims[0] = str2nr( delims[0] ) - 1
    delims[1] = str2nr( delims[1] ) - 1
    return list_ranges + [ tb[delims[0]][delims[1]] ]
  elseif rng =~ '@\d*\$\d*\.\.@\d*\$\d*$'
    delims = split( rng, '\.\.' )
    delims = split( rng[1 : ], '\$' )
    delims[0] = str2nr( delims[0] ) - 1
    delims[1] = str2nr( delims[1] ) - 1
    return list_ranges + [ tb[delims[0]][delims[1]] ]
  endif
  return list_ranges
enddef

export def TbConditions(rng: string): string
  var threated_data = ''
  return threated_data
enddef


