if has('nvim')
  finish
endif

if v:version > 800
  finish
endif

vim9script

export def Search_nm(patt: string): number
  var returned = search( patt, 'n' )
  return returned
enddef

export def Search_nm_b(patt: string): number
  var returned = search( patt, 'nb' )
  return returned
enddef

export def Curr_pos_nb(): list<any>
  var returned = getcurpos()
  return returned[ 1 : 2 ]
enddef
