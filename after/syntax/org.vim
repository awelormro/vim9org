" call 

function! s:NotCodeBlock(lnum) abort
  return synIDattr(synID(a:lnum, 1, 1), 'name') !=# 'OrgCodeBlock'
endfunction

function! OrgFolding() abort
  let line = getline(v:lnum)

  if line =~# '^\*\+ ' && s:NotCodeBlock(v:lnum)
    return ">" . match(line, ' ')
  endif

  let nextline = getline(v:lnum + 1)
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">1"
  endif

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">2"
  endif

  return "="
endfunction

" setlocal foldexpr=OrgFolding()
" syntax clear
" syntax off
" syntax on 
" syntax enable
" call CallSyntaxRange()
