" vim: set fdm=marker:
" Vimscript start {{{
if !has('vim9script')
function! Ntcodeblock(x)
  return synIDattr(synID(a:x, 1, 1), 'name') !=# 'OrgCodeBlock'
endfunction
function! OrgFolding() abort
  let line = getline(v:lnum)
  if line =~ '^\s*:PROPERTIES:$'
    return "a1"
  endif
  if line =~ '^\s*:END:$'
    return 's1'
  endif
  if line =~ "#+BEGIN_"
    return "a2"
  endif
  if line =~ "#+END_"
    return "s2"
  endif
  if line =~ " {{{"
    return "a1"
  endif
  if line =~ " }}}"
    return "s1"
  endif
  if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
    return ">" .. match(line, ' ')
  endif
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
    return ">1"
  endif 
  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
    return ">2"
  endif
  return "="
  return foldlevel(v:lnum-1)
  " if foldlevel(v:lnum-1) == 0
  "   return '='
  " else
  "   return foldlevel(v:lnum-1)
  " endif
endfunction

setlocal foldmethod=expr
setlocal foldexpr=OrgFolding()
" setlocal foldexpr=Orgfoldexpr
" setlocal foldexpr=OrgFoldingExpr()
finish
endif
" }}}
vim9script


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

# Activar/desactivar caché automáticamente
# augroup OrgFoldCache
#   autocmd!
#   autocmd InsertEnter *.org {
#     b:fold_cache_enabled = 1
#     b:fold_cache = {}  # Resetear caché al entrar en inserción
#   }
#   autocmd InsertLeave *.org {
#     b:fold_cache_enabled = 0
#     b:fold_cache = {}  # Limpiar caché al salir
#     setlocal foldmethod=expr  # Forzar actualización
#   }
# augroup END

# setlocal foldmethod=expr
# setlocal foldexpr=OrgFold9s(v:lnum)
# }}}
