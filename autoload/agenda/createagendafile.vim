vim9script
# vim: set foldmethod=marker:
export def ReadAgendaFiles() # {{{
  if !exists('g:orgagendafiles')
    g:orgagendafiles = '~/orgagenda'
  endif
  var agendafiles = g:orgagendafiles
  # Crear un buffer nuevo para mostrar la agenda
  enew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  call setline(1, "Agenda Overview")

  # Inicializar la línea en la que empezaremos a escribir
  var line_num = 3

  # Recorrer los archivos de la lista
  for file in g:orgagendafiles
    var expanded_file = expand(file)

    # Verificar si el archivo existe
    if filereadable(expanded_file)
      # Leer el contenido del archivo
      var lines = readfile(expanded_file)

      # Buscar y mostrar las tareas con TODO y DONE
      for l in lines
        if l =~ '\v^\s*\*+\s+(TODO|DONE)\s'
          call setline(line_num, l)
          line_num += 1
        endif
      endfor
    else
      call setline(line_num, "Archivo no encontrado: " .. expanded_file)
      line_num += 1
    endif

    call setline(line_num, "")
    line_num += 1
  endfor
enddef #  }}}
