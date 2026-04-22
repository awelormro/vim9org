function! indent#OrgIndenter() " {{{
  " let pnonblank = prevnonblank(v:lnum)
  " let pline = getline(v:lnum - 1)  " Obtiene la línea anterior
  let pnonblank = prevnonblank(v:lnum - 1)
  let pline = getline(pnonblank)
  " let level = indent(v:lnum - 1)   " Obtiene la sangría de la línea anterior
  let level = indent( pnonblank )

  " Si la línea anterior está vacía o solo tiene espacios, mantener la sangría actual
  if pline =~ '^\s*$'
    return level
  endif

  " Detectar patrones y ajustar la sangría
  if pline =~ '^\*\{1,6} '
    " Sangría para títulos (ej: *, **, ***, etc.)
    return len(matchstr(pline, '^\*\+')) + 1
  elseif pline =~ '^\s*- \[X\]'
    " Sangría para listas de tareas (ej: - [ ])
    return level + 6
  elseif pline =~ '^\s*- \[x\]'
    " Sangría para listas de tareas (ej: - [ ])
    return level + 6
  elseif pline =~ '^\s*- \[o\]'
    " Sangría para listas de tareas (ej: - [ ])
    return level + 6
  elseif pline =~ '^\s*- \[ \]'
    " Sangría para listas de tareas (ej: - [ ])
    return level + 6
  elseif pline =~ '^\s*\d\d\d[\.\)] '
    " Sangría para listas numeradas con 3 dígitos (ej: 100.)
    return level + 5
  elseif pline =~ '^\s*[0-9i]\{2}[\.\)] '
    " Sangría para listas numeradas con 2 dígitos (ej: 10.)
    return level + 4
  elseif pline =~ '^\s*\d[\.\)] '
    " Sangría para listas numeradas con 1 dígito (ej: 1.)
    return level + 3
  elseif pline =~ '^\s*\a[\.\)]\s'
    " Sangría para listas con letras (ej: a.)
    return level + 3
  elseif pline =~ '^\s*[+-\*] '
    " Sangría para listas con viñetas (ej: -, +, *)
    return level + 2
  endif

  " Si no coincide con ningún patrón, mantener la sangría actual
  return level
endfunction " }}}
