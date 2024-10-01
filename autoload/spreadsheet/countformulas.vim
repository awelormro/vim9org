vim9script
# vim: set fdm=marker:
# vim: set nospell:
# Lógica: Checar si hay fórmulas
# Checar si hay fórmulas anidadas
# Resolver fórmulas anidadas y sustituir valores
# Así hasta tener fórmulas prinicipales
# Resolver fórmulas prinicipales
# Sustituir en celda
# Termina
# /home/abu/Plantillas/vim9org/autoload/spreadsheet/extractdata.vim
import autoload "base/counters/linecounters.vim" as lnc
import autoload "base/counters/stringcounters.vim" as snc
import autoload "spreadsheet/extractdata.vim" as extdta
export def CalculateFormulas(frmla: string, tb: list<any>): string
  var startlist = Datainfo( frmla )
  var frmlaprevcont = startlist[1]
  startlist[1] = SubstituteInStrigs( startlist[1] )
  echo frmlaprevcont
  # echo startlist
  var stridlst6 = ObtainNest( startlist[1] )
  echo stridlst6
  var minfrml = FrmlaData( stridlst6 )
  var exist2 = Rngs2list( minfrml, startlist, tb )
  # echo exist2
  return ''
enddef

export def RetainFormulaInfo(strn: string): string
  
enddef

export def SubstituteInStrigs(strn: string): string
  var numbrofdq = count( strn, '"' )
  echo numbrofdq
  var i = 0
  var cont = 0
  var prevpos = 0
  var rowslist = []
  var alllist = []
  var retstr = ''
  if numbrofdq / 2 * 2 == numbrofdq
    rowslist = []
    while cont < numbrofdq
      rowslist = []
      prevpos = stridx( strn, '"', i )
      add( rowslist, prevpos )
      i = prevpos + 1
      cont += 1
      prevpos = stridx( strn, '"', i )
      add( rowslist, prevpos )
      i = prevpos + 1
      cont += 1
      add( alllist, rowslist )
    endwhile
    var allstr = strn
    var auxstring = ''
    for rng in alllist
      auxstring = strn[ rng[0] : rng[1] ]
      auxstring = substitute( auxstring, '(', '{{{orgopnbrck}}}', 'g' )
      auxstring = substitute( auxstring, ')', '{{{orgclobrck}}}', 'g' )
      auxstring = substitute( auxstring, ',', '{{{orgcommasep}}}', 'g' )
      allstr = substitute( allstr, strn[ rng[0] : rng[1] ], auxstring, '' )
      echo auxstring
      echo allstr
    endfor
    echo alllist
    return allstr
  else
    echoerr "Not closed strings"
    return 'ERR'
  endif
enddef
export def ObtainNest(frmla: string): string # {{{ 
  var i = 0
  var parbeg = match( frmla, '(', i )
  var frmlbeg = match( frmla, '\a*(', i )
  var frmlend = stridx( frmla, ')' )
  # echo parbeg
  var cutstr = frmla[ frmlbeg : frmlend ]
  # echo cutstr
  while i > -1
    if count( cutstr[ frmlbeg : frmlend ], '(' ) > 1
      parbeg = match( cutstr, '(', parbeg + 1 )
      frmlbeg = match( cutstr, '\a*(', parbeg + 1 )
      cutstr = cutstr[ frmlbeg : frmlend ]
      i = frmlbeg
    else
      return cutstr
    endif
    i += 1
  endwhile
  return cutstr
enddef #  }}}
export def FrmlaData(frmla: string): list<any> # {{{ 
  var i = 0
  var frlsep = match( frmla, '(')
  var frmlalist = [ frmla[ : frlsep - 1 ],  split(frmla[ frlsep + 1 : -2 ], ',')]
  echo frmlalist
  return frmlalist
enddef # }}}

export def Datainfo(frml: string): list<any>
  var cll_start = stridx( frml, '=' )
  var alllist = [ 
    split(frml[ 1 : cll_start - 1 ], '\$'),
    frml[ cll_start + 1 : ]
  ]
  var i = 0
  while i < len( alllist[0] )
    alllist[0][i] = str2nr( alllist[0][i] )
    i += 1
  endwhile
  return alllist
enddef

export def Rngs2list(dtainfo: list<any>, cll: list<any>, tb: list<any>): list<any>
  var alllist = []
  var type_range = {
  'Cell': '@\d*\$\d*',
  'Range': '@\d*\$\d*\.\.@\d*\$\d*',
  'RangeCol': '\$\d*\.\.\$\d*',
  'RangeRow': '@\d*\.\.@\d*',
  'CurrCol': '@\d*',
  'CurrRow': '\$\d*',
  'Empty': '^\s*$',
  'Currency': '^\s*\$\s\d*\.\d*\s*',
  'Float': '^\s*\d*\.\d*\s*$',
  'Number': '^\s*\d*\s*$',
  'String': '^\s*\a*\s*$'
  }
  var listaux = []
  echo dtainfo
  for dta in dtainfo[1]
    # echo dta
    listaux = listaux + Rng2list(cll, dta, tb)
  endfor
  # echo cll
  return []
enddef


export def Rng2list(cll: list<any>, rng: string, tb: list<any>): list<any>
  var type_range = {
  'Cell':     '^@\d*\$\d*',
  'Range':    '^@\d*\$\d*\.\.@\d*\$\d*',
  'RangeCol': '^\$\d*\.\.\$\d*',
  'RangeRow': '^@\d*\.\.@\d*',
  'CurrCol':  '^@\d*',
  'CurrRow':  '^\$\d*',
  'Empty':    '^\s*$',
  'Currency': '^\s*\$\s\d*\.\d*\s*',
  'Float':    '^\s*\d*\.\d*\s*$',
  'Number':   '^\s*\d*\s*$',
  'String':   '^\s*\a*\s*$'
  }
  # echo cll[0]
  var i = 0
  var j = 0
  if rng =~ type_range['Cell']
    echo 'cell'
    i = cll[0][0] - 1
    j = cll[0][1] - 1
    echo i
    echo j
    echo tb[cll[0][0] - 1][cll[0][1] - 1]
    return tb[i][j]
  elseif rng =~ type_range['Range']
    echo 'RangeCells'
  elseif rng =~ type_range['RangeCol']
    echo 'RangeCol'
  elseif rng =~ type_range['RangeRow']
    echo 'RangeRow'
  elseif rng =~ type_range['CurrCol']
    echo 'CurrCol'
    echo 'cell'
    i = cll[0][0] - 1
    j = str2nr( rng[ 1 : ] )
    echo i
    echo j
    echo tb[i][j]
    return [ tb[i][j] ]
  elseif rng =~ type_range['CurrRow']
    echo 'CurrRow'
    i = str2nr( rng[ 1 : ] )
    j = cll[0][1] - 1
    echo i
    echo j
    echo tb[i][j]
    return [ tb[i][j] ]
  elseif rng =~ type_range['Empty']
    echo 'Empty'
  elseif rng =~ type_range['Currency']
    echo 'Currency'
  elseif rng =~ type_range['Float']
    echo 'Float'
  elseif rng =~ type_range['Number']
    echo 'Number'
  elseif rng =~ type_range['String']
    echo 'String'
  else
    echo 'string'
  endif
  # echo rng
  return []
enddef


