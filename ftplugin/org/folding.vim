" vim: set fdm=marker:
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
" }}}
function! Orgfoldexpr()
  let line = getline(v:lnum)
  if line =~ '^\*' || line =~ '^\s:' || line =~ '^\s#\+*' 
    if line =~ '^\s*:PROPERTIES:$'
      let b:prevfold = foldlevel(v:lnum-1)
      return "a1"
    endif
    if line =~ '^\s*:END:$'
      return 's1'
    endif
    if line =~ "#+BEGIN_"
      let b:prevfold = foldlevel(v:lnum-1)
      return "a2"
    endif
    if line =~ "#+END_"
      return "s2"
    endif
    if line =~ " {{{"
      let b:prevfold = foldlevel(v:lnum-1)
      return "a1"
    endif
    if line =~ " }}}"
      return "s1"
    endif
    if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
      return ">" .. match(line, ' ')
    endif
    if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
      let b:prevfold = 
      return ">1"
    endif 
    if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
      return ">2"
    endif
  else
    return foldlevel(b:prevfold)
  endif
endfunction


function! OrgFoldingExpr()
  let l = getline(v:lnum)

  " Saltar líneas vacías o sin elementos clave
  if l =~ '^\s*$' || l !~ '^\s*\(\*\|[-+]\|[0-9]\+\.\|#\+BEGIN\|#\+END\)'
    return '='
  endif

  " Encabezados Orgmode
  if l =~ '^\s*\*'
    return '>' . matchstr(l, '^\s*\*\+')->count('*')
  endif

  " Bloques #+BEGIN y #+END
  if l =~ '^\s*#\+BEGIN'
    return 'a1'
  endif
  if l =~ '^\s*#\+END'
    return 's1'
  endif

  " Listas
  " if l =~ '^\s*\([-+]\|[0-9]\+\.\)\s'
  "   return '1'
  " endif

  return '='
endfunction


setlocal foldmethod=expr
setlocal foldexpr=OrgFolding()
" setlocal foldexpr=Orgfoldexpr
" setlocal foldexpr=OrgFoldingExpr()
