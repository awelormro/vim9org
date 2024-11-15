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
export def AgendaReadFiles() # {{{
  # Declare variables, create agenda files in case to be necessary {{{
  if !exists('g:org_agenda_files')
    g:org_agenda_files = [ expand('~/orgagenda.org') ]
  endif
  if !exists('g:org_agenda_folder')
    g:org_agenda_folders = [ expand( '~/agendadir/' )]
  endif
  var agendafiles = [] # Variable used to generate volatile agenda lists
  var allagendafiles = [  ] # Variable used to store all the information
  var todoheaders = [] # variable containing all the headers.
  var buf_content = [ ]
  var buf_header = []
  # }}}
  # Generate the entries for all the agenda files in one variable {{{
  for agendapath in g:org_agenda_folders
    agendafiles = readdir( agendapath,  (n: string) =>  n =~ '.org$'  )
    # agendafiles = readdir( agendapath )
    allagendafiles = extend( allagendafiles, agendafiles )
  endfor
  echo allagendafiles
  for agendafile in g:org_agenda_files
    allagendafiles = add( allagendafiles, agendafile )
  endfor # }}}
  # Read every file and check if it has the asterisk at the very start {{{
  for agendafile in allagendafiles
    buf_content = readfile(agendafile)
    for cont_buf in buf_content
      if cont_buf =~ '^\*'
        add(buf_header, cont_buf)
      endif
    endfor
  endfor  # }}}
enddef # }}}
