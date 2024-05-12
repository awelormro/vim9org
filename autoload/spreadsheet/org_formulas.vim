vim9script
# vim: set fdm=marker:
# vim: set nospell:
# Calculate the sum of the params
export def VsumCalc(vls: list<string>): string # {{{
  var valaux = 0.0
  var list_aux = []
  var list_vals = []
  for val in vls
    add( list_aux, KindOfDataValue(val) )
  endfor
  if count( list_aux, 'Text' ) > 0
    return 'ERR'
  endif
  var list_vals_sum = []
  var typefinal = ''
  var straux = ''
  for elem in vls
    if list_aux[index( vls, elem )] == 'Currency'
      # echo 'has a currency value '
      straux =  substitute( elem, '\$', '', '' )
      # echo straux
      # echo str2float( trim( straux ) )
      add( list_vals_sum, straux)
      typefinal = 'Curr'
    else
      add( list_vals_sum, elem )
    endif
  endfor
  for val in list_vals_sum
    valaux += str2float( val )
  endfor
  if typefinal == 'Curr'
    return '$ ' .. string( valaux )
  else
    return string(valaux)
  endif
enddef
# }}}
# Calculate the mean
export def VmeanCalc(vls: list<string>): string # {{{
  var valaux = 0.0
  var list_aux = []
  var list_vals = []
  for val in vls
    add( list_aux, KindOfDataValue(val) )
  endfor
  if count( list_aux, 'Text' ) > 0
    return 'ERR'
  endif
  var list_vals_sum = []
  var typefinal = ''
  var straux = ''
  for elem in vls
    if list_aux[index( vls, elem )] == 'Currency'
      # echo 'has a currency value '
      straux =  substitute( elem, '\$', '', '' )
      # echo straux
      # echo str2float( trim( straux ) )
      add( list_vals_sum, straux)
      typefinal = 'Curr'
    else
      add( list_vals_sum, elem )
    endif
  endfor
  for val in list_vals_sum
    valaux += str2float( val )
  endfor
  if typefinal == 'Curr'
    return '$ ' .. string( valaux / len( vls ) )
  else
    return string(valaux / len( vls ))
  endif
enddef
# }}}
# Obtain The min value
export def VminCalc(vls: list<string>): string # {{{
  var valaux = 0.0
  var list_aux = []
  var list_vals = []
  for val in vls
    add( list_aux, KindOfDataValue(val) )
  endfor
  if count( list_aux, 'Text' ) > 0
    return 'ERR'
  endif
  var list_vals_sum = []
  var typefinal = ''
  var straux = ''
  if index( list_aux, 'Empty' ) > 0
    return '0'
  endif
  var trimmed_list = []
  for elem in vls
    add( trimmed_list, trim( elem ) )
  endfor
  for elem in vls
    if list_aux[index( vls, elem )] == 'Currency'
      # echo 'has a currency value '
      straux =  substitute( elem, '\$', '', '' )
      # echo straux
      # echo str2float( trim( straux ) )
      add( list_vals_sum, str2float(straux))
      # typefinal = 'Curr'
    else
      add( list_vals_sum, str2float( elem ) )
    endif
  endfor
  var minval = list_vals_sum[0]
  for elem in list_vals_sum
    if elem < minval
      minval = elem
    endif
  endfor
  if index( trimmed_list, '\$ ' .. minval ) > -1
    return '$ ' .. string(minval)
  else
    return string( minval )
  endif
enddef
# }}}
# Obtain The max value
export def VmaxCalc(vls: list<string>): string # {{{
  var valaux = 0.0
  var list_aux = []
  var list_vals = []
  for val in vls
    add( list_aux, KindOfDataValue(val) )
  endfor
  if count( list_aux, 'Text' ) > 0
    return 'ERR'
  endif
  var list_vals_sum = []
  var typefinal = ''
  var straux = ''
  if index( list_aux, 'Empty' ) > 0
    return '0'
  endif
  var trimmed_list = []
  for elem in vls
    add( trimmed_list, trim( elem ) )
  endfor
  for elem in vls
    if list_aux[index( vls, elem )] == 'Currency'
      # echo 'has a currency value '
      straux =  substitute( elem, '\$', '', '' )
      # echo straux
      # echo str2float( trim( straux ) )
      add( list_vals_sum, str2float(straux))
      # typefinal = 'Curr'
    else
      add( list_vals_sum, str2float( elem ) )
    endif
  endfor
  var maxval = list_vals_sum[0]
  for elem in list_vals_sum
    if elem > maxval
      maxval = elem
    endif
  endfor
  if index( trimmed_list, '\$ ' .. maxval ) > -1
    return '$ ' .. string(maxval)
  else
    return string( maxval )
  endif
enddef
# }}}
# Obtain the mode
export def VmodeCalc(vals: list<string>): string # {{{
  var maxcount = []
  # Trim all elements to can be counted
  for elem in vals
    add( maxcount, trim(elem) )
  endfor
  # echo maxcount
  var undupslist = []
  # Count element in list, if not exists, add to list
  for elem in maxcount
    if count( undupslist, elem ) <= 0
      add(undupslist, elem)
    endif
  endfor
  var i = 0
  var maxstr = ''
  for elem in undupslist
    if count(maxcount, elem) > i
      i = count( maxcount, elem )
      maxstr = elem
    endif
  endfor
  return maxstr
  # echo undupslist
  # echo 
  # return ''
enddef
#  }}}
# Obtain the median
export def VmedianCalc(vals: list<string>): string # {{{
  var trimmed_list = []
  var list_vals_kind = []
  # First, Check the majority of data
  for elem in vals
    add( list_vals_kind, KindOfDataValue(elem) )
  endfor
  if count( list_vals_kind, 'Text' ) < count( list_vals_kind, 'Float' ) + 
      count( list_vals_kind, 'Number' ) + count( list_vals_kind, 'Currency' )
    echo 'All be threated as number'

  endif
  for vl in vals
    add( trimmed_list, trim(vl) )
  endfor
  sort(trimmed_list)
  echo trimmed_list
  # Will make the median the medium previous value
  return trimmed_list[ len( trimmed_list ) / 2  ]
enddef
# }}}
# Concatenate the values on a list
export def VconcatMake(vals: list<string>): string # {{{

  var auxstring = ''
  for stri in vals
    auxstring = auxstring .. stri
  endfor
  return auxstring
enddef
# }}}
# Start a simple unit converter
export def VconvertUnits(vals: list<string>): string
  if len( vals ) != 3
    return 'ERR'
  endif
  if KindOfDataValue( vals[0] ) == 'Text'
    return 'ERR'
  endif
  var init_val = str2float( vals[0] ) 
  var list_units = { 
    'm': [ 1, 1 / 1000], 
    'km': [1000, 1]
  }
  var factors_conv = init_val * list_units[vals[1]][0] * list_units[vals[2]][0]
  return string( factors_conv )
enddef
# Experimental function to use vimscript, it allows to evaluate the arguments
# inside the formula
export def VEvalVscript(val: string): string
  return string(eval( val ))
enddef
export def VevalIf(vals: list<string>): string

enddef
def KindOfDataValue(strng: string): string # {{{
  var list_kinds = [ 'Empty', 'Text', 'Currency', 'Float', 'Number',  ]
  var list_kinds_defs = [ '^\s*$', '^\s*\a', '^\s*\$\s\d*\.\d*\s*$', '^\s*\d*\.\d*\s*$', '^\s*\d*\s*$',  ]
  for kind in list_kinds_defs
    if strng =~ kind
      return list_kinds[index( list_kinds_defs, kind )]
    endif
  endfor
  return ''
enddef
# }}}
