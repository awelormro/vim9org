if !has('vim9script')
  finish
endif
vim9script

export def Stridxrev( st: string, pat: string, pos: number = 0 ): number
  var rev_list = reverse(join( split(st, '\sz')) )
  var rev_par =  reverse(join( split(pat, '\sz')) )
  var rev_pos = len( st ) - pos
  var returned = stridx(rev_list, rev_par, rev_pos)
  return returned
enddef

export def Is_inside_pattern( st: string, beg: string, end: string, pos: number = 0 ): bool
  var is_inside = true
  var ret = stridx( st, end, pos ) >= 0 ? true : false
  var ret = Stridxrev( st, beg, pos ) <= 0 ? true : false
  return ret
enddef


# Busca la última ocurrencia de un patrón antes de una posición (stridx en reversa)
export def Stridxrev1(st: string, pat: string, pos: number = -1): number
    # Si pos es -1 (o no se da), empezamos desde el final de la cuerda
    var start_pos = (pos == -1) ? len(st) : pos
    
    # strridx es la función nativa de Vim para "string reverse index"
    # Es mucho más rápida que invertir strings manualmente
    return strridx(st, pat, start_pos)
enddef

export def Is_inside_pattern1(st: string, beg: string, ending: string, pos: number): bool
    # 1. Buscamos el delimitador de inicio hacia atrás desde la posición actual
    var last_beg = strridx(st, beg, pos)
    
    # 2. Buscamos el delimitador de cierre hacia adelante desde la posición actual
    var next_end = stridx(st, ending, pos)
    
    # Si encontramos ambos (index != -1), el cursor está "dentro"
    return last_beg != -1 && next_end != -1
enddef
