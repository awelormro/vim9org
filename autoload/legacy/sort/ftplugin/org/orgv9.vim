if !has('vim9script')
  finish
endif
vim9script

if !exists('g:org_backend')
  g:org_backend = 'vim9script'
endif

if g:org_backend != 'vim9script'
  finish
endif

if exists('b:org_started')
  finish
endif

b:org_started = 1

import autoload "v9sc/start.vim" as start
start.General_start()

def OrgFold9s(lnum: number): string
  # Cachear folds durante inserción o si ya está calculado
  if mode() == 'i' || exists('b:fold_cache_enabled') && b:fold_cache_enabled
    if !exists('b:fold_cache')
      b:fold_cache = {}
    endif
    if has_key(b:fold_cache, lnum)
      return b:fold_cache[lnum]
    endif
    # Si no está en caché, calcular y guardar (solo primera vez en inserción)
    var foldval = CalculateRealFold(lnum)
    b:fold_cache[lnum] = foldval
    return foldval
  endif
  # Limpiar caché al salir del modo inserción
  return CalculateRealFold(lnum)
enddef

def CalculateRealFold(lnum: number): string
  var Ntcodeblock = (x) => synIDattr(synID(x, 1, 1), 'name') !=# 'OrgCodeBlock'
  var line = getline(lnum)
  var nextline = getline(lnum + 1)

  if line =~# '^\s*:PROPERTIES:$' || line =~# "#+BEGIN_" || line =~# " {{{"
    return "a7"
  elseif line =~# '^\s*:END:$' || line =~# "#+END_" || line =~# " }}}"
    return "s7"
  elseif line =~# '^\*\+ ' && Ntcodeblock(lnum)
    return ">" .. match(line, ' ')
  elseif (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(lnum + 1)
    return ">1"
  elseif (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(lnum + 1)
    return ">2"
  endif
  return "="
enddef

setlocal foldmethod=expr
setlocal foldexpr=OrgFold9s(v:lnum)
