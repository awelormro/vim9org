vim9script
# vim: set fdm=marker:
# vim: set nospell:

export def StridxLst(strn: string, smbol: string): list<any> # List of stridx in string {{{
  var i = 0
  var lst = []
  var comp = 0
  while i > -1
    comp = stridx(strn, smbol, i)
    if comp > -1
      add( lst, comp )
      i = comp + 1
    else
      return lst
    endif
  endwhile
  return lst
enddef #  }}}

export def MtchList(strn: string, ptt: string): list<any> # {{{
  var i = 0
  var lst = []
  var comp = 0
  while i > -1
    comp = match(strn, ptt, i)
    if comp > -1
      add( lst, comp )
      i = comp + 1
    else
      return lst
    endif
  endwhile
  return lst
enddef #  }}}

export def SortTilMinPairsTxt(strn: string, prslst: list<any>): string
  var i = 0
  var cutstr = strn
  echo cutstr
  var prslist = MtchList( strn, '\a\a(' )
  var cbidx = stridx(strn, ')')
  while i > -1 && i < len(prslist)
    if count( cutstr, '(' ) > 1
      cutstr = cutstr[ prslst[i] : cbidx ]
      echo cutstr
      i += 1
    else
      return cutstr
    endif
  endwhile
  echo cutstr
  return cutstr
enddef
