vim9script
# vim: set fdm=marker:
# vim: set nospell:
import autoload "base/counters/linecounters.vim" as lnc
import autoload "base/counters/stringcounters.vim" as snc
export def CalculateFormulas(frmla: string, tb: list<any>): string
  var startlist = Datainfo( frmla )
  echo startlist
  var stridlst6 = ObtainNest( startlist[1] )
  echo stridlst6
  var exsit1 = FrmlaData( stridlst6 )
  var exist2 = Rngs2list( exsit1, startlist, tb )
  echo exist2
  return ''
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
  return []
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
  'String': '^\s*\w*\s*$'
  }
  var i = 0
  var direct_append = [ 'Currency', 'Float', 'Number', 'String' ]
  while i < len( dtainfo[1] )
    echo i
    i += 1
  endwhile
  for el in keys( type_range )
    echo type_range[el]
  endfor
  return []
enddef


export def Rng2list(cll: list<any>, rng: string, tb: list<any>): list<any>
  var i = 0
  var j = 0
  var alllist = []
  while i < len( tb )
    j = 0
    while j < len( tb[0] ) && j < tbend
      add( alllist, tb[i - 1][j - 0] )
      j += 1
    endwhile
  endwhile
enddef
