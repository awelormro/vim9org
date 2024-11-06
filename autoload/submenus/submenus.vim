vim9script
# vim: set foldmethod=marker:
#
# Navigation commands {{{

export def MoveRight() # {{{
  call search('[')
  var lcol = col('.')
  var lrow = line('.')
  call cursor(lrow, lcol + 1)
enddef # }}}
export def MoveLeft() # {{{
  var newpos = search('[', 'b')  
  call search('[', 'b')
  call cursor(line('.'), col('.') + 1)
enddef # }}}

#  }}}
# Menus to generate {{{
export def MenuExporter() # {{{
  # 1. Guarda el número del buffer actual en una variable
  var current_buf = bufnr('%')
  # 2. Abre un nuevo buffer vacío
  :5new
  call setline(1, 'Org menu file Pandoc exporter')
  call setline(2, '[p] Pdf Export via pandoc        [d] Docx export via pandoc')
  call setline(3, '[m] Md  Export via pandoc        [w] HTML export via pandoc')
  call setline(4, '[b] Beamer Export via pandoc     [t] txt export via pandoc')
  call setline(5, '[q] Quit menu')
  call cursor(2, 2)
  # setlocal nomodifiable nomodified
  g:current_org_submenu = 'exporter'
  b:current_org_submenu = 'exporter'
  set filetype=orgmenu
  var commandkeys = [ ['p', 'pdf'], ['d', 'docx'], ['m', 'markdown'], ['w', 'html'], ['b', 'beamer'], ['t', 'rtf'],]
  # var  = 
  for commandkey in commandkeys
    execute 'nnoremap <buffer><silent> ' .. commandkey[0] .. ' :bd!<CR>:OrgConvertToFormat ' .. commandkey[1] .. '<CR>'
  endfor
  nnoremap <buffer><silent> q :bd!<CR>
enddef # }}}
export def CountAllHeaders() # {{{
  var i = 1
  var lend = line('$')
  b:alltitles = []
  while i < lend
    # if getline(i) =~ '^\**\s'
    if getline(i) =~ '^\*'
      # echo 'has title'
      add(b:alltitles, [getline(i), i])
    endif
    i += 1
  endwhile
  # for tit in b:alltitles
  #   echo tit
  # endfor
enddef
# }}}
export def HeaderSubmenu() # {{{
  if !exists('b:alltitles')
    CountAllHeaders()
  endif
  # Declare variables {{{
  var countasterisks = 0
  var newtitle = ''
  var buftitles = []
  var head1 = 0
  var head2 = 0
  var head3 = 0
  var head4 = 0
  var head5 = 0
  var head6 = 0
  var head7 = 0
  var head8 = 0
  var bname = bufname()
  # }}}
  # loop for titles generation {{{
  for title in b:alltitles
    if title[0] =~ '^\* '
      head1 += 1
      head2 = 0
      head3 = 0
      head4 = 0
      head5 = 0
      newtitle = string(head1) .. '.' .. substitute(title[0], "*", '', 'g')
      add(buftitles, [newtitle, title[1]])
      # echo newtitle
    elseif title[0] =~ '^\*\* '
      head2 += 1
      head3 = 0
      head4 = 0
      head5 = 0
      newtitle = string(head1) .. '.' .. string(head2) .. substitute(title[0], "*", '', 'g')
      # echo newtitle
      # add(buftitles, newtitle)
      add(buftitles, [newtitle, title[1]])
    elseif title[0] =~ '^\*\*\* '
      head3 += 1
      head4 = 0
      head5 = 0
      newtitle = string(head1) .. '.' .. string(head2) .. '.' .. string(head3)
                 .. substitute(title[0], "*", '', 'g')
      # echo newtitle
      # add(buftitles, newtitle)
      add(buftitles, [newtitle, title[1]])
    elseif title[0] =~ '^\*\*\*\* '
      head4 += 1
      head5 = 0
      newtitle = string(head1) .. '.' .. string(head2) .. '.' .. string(head3) 
                 .. '.' .. string(head4) .. substitute(title[0], "*", '', 'g')
      # echo newtitle
      # add(buftitles, newtitle)
      add(buftitles, [newtitle, title[1]])
    elseif title[0] =~ '^\*\*\*\*\* '
      head5 += 1
      newtitle = string(head1) .. '.' .. string(head2) .. '.' 
                 .. string(head3) .. '.' .. string(head4) .. 
                 string(head5) .. substitute(title[0], "*", '', 'g')
      # echo newtitle
      # add(buftitles, newtitle)
      add(buftitles, [newtitle, title[1]])
    endif
  endfor
  # for title in buftitles
  #   echo title
  # endfor
  # }}}
  # Add Buffer with indications {{{
  var i = 0
  :30vnew
  setline(1, 'Org Index')
  setline(2, 'Press <CR> for go to file')
  setline(3, 'Press q to exit')
  setline(4, '')
  for line in buftitles
    i += 1
    setline(i + 4, line[0])
  endfor
  b:buftitles = buftitles
  b:searchbuf = bname
  setlocal bufhidden=wipe buftype=nofile nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber
  execute ':5'
  command -buffer OrgIndexSearch SearchHeader()
  nnoremap <buffer><silent> q :bd!<CR>
  nnoremap <buffer><silent> <CR> :OrgIndexSearch<CR>
  # }}}

enddef # }}}
export def SearchHeader(index: list<any> = b:buftitles, numbuf: string = b:searchbuf) # {{{
  b:contentlist = []
  var wheretojump = 0
  for val in index
    add(b:contentlist, val[0])
  endfor
  var conts = b:contentlist
  var linec = getline('.')
  if index(b:contentlist, linec) > -1
    # echo 'Can jump'
    wheretojump = index[index(b:contentlist, linec)][1]
    SwitchToBufferInVisibleWindows(numbuf)
    execute ':' .. wheretojump
    # execute (search)
  endif

enddef # }}}
def SwitchToBufferInVisibleWindows(buffer_name: string) # {{{
  # Recorre todas las ventanas visibles
  for i in range(1, winnr('$'))
    # Cambia a cada ventana
    execute ':' .. i .. 'wincmd w'
    # Verifica si el nombre del buffer actual coincide
    if bufname('%') == buffer_name
      return
    endif
  endfor
  # Si no encuentra el buffer, muestra un mensaje
  echo "Buffer no encontrado en ventanas visibles"
enddef # }}}
#  }}}

# Mapea la función para facilitar su uso
# command! -nargs=1 SwitchBuffer SwitchToBufferInVisibleWindows(<f-args>)
