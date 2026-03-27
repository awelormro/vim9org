if !has('vim9script') " {{{
  finish
endif " }}}

vim9script

export def Todo_Search(fw: bool) # {{{
  # Buscamos hacia atrás el encabezado más cercano
  var line_todo = search('^\*\{1,\} ', 'nbW')
  if line_todo <= 0
    return # En Vim9script, 'return' es preferible a 'finish' dentro de def
  endif

  var line_content = getline(line_todo)

  # Definir la lista de keywords (usando variables locales para limpieza)
  var todo_list: list<string> = exists('g:org_todo_list') ? g:org_todo_list : ['TODO', 'DOING', 'DONE']

  var parts = split(line_content)
  if len(parts) < 2
    # Si solo hay asteriscos, añadimos el primer o último keyword
    if fw
      Add_kw(line_content, line_todo, todo_list[0])
    else
      Add_kw(line_content, line_todo, todo_list[-1])
    endif
    return
  endif

  var current_kw = parts[1]
  var idx = index(todo_list, current_kw)

  if idx == -1
    # El segundo elemento no es un keyword, insertar uno nuevo
    Add_kw(line_content, line_todo, fw ? todo_list[0] : todo_list[-1])
  else
    # Es un keyword existente, rotar
    Rotate_kw(line_content, line_todo, todo_list, idx, fw)
  endif
enddef # }}}

def Add_kw(content: string, lnum: number, kw: string) # {{{
  # Reemplaza el primer grupo de asteriscos y espacio por asteriscos + espacio + keyword
  var new_line = substitute(content, '^\(\*\{1,\}\s\)', '\1' .. kw .. ' ', '')
  setline(lnum, new_line)
enddef # }}}

def Rotate_kw(content: string, lnum: number, todo_list: list<string>, idx: number, fw: bool)  # {{{
  var new_idx = fw ? idx + 1 : idx - 1
  var new_line = ""

  if new_idx >= len(todo_list) || new_idx < 0
    # Eliminar el keyword (ciclo completado)
    new_line = substitute(content, '^\(\*\{1,\}\s\)' .. todo_list[idx] .. '\s*', '\1', '')
  else
    # Reemplazar el keyword viejo por el nuevo
    var next_kw = todo_list[new_idx]
    new_line = substitute(content, '^\(\*\{1,\}\s\)' .. todo_list[idx], '\1' .. next_kw, '')
  endif

  setline(lnum, new_line)
enddef # }}}

# --- 1. Configuración de Prioridades ---
def Todo_priorities_defaults()
    # Aseguramos que el nivel sea un número, no un string
    if !exists('g:org_todo_priorities_level')
        g:org_todo_priorities_level = 3
    endif

    var all_kinds: list<string> = []
    var p_type = get(g:, 'org_todo_priorities_type', 'alphabetic')

    if p_type == 'alphabetic'
        all_kinds = ['A', 'B', 'C', 'D', 'E', 'F'] # Simplificado para el ejemplo
    elseif p_type == 'numerical'
        all_kinds = ['1', '2', '3', '4', '5']
    else
        all_kinds = get(g:, 'org_prior_custom', ['A', 'B', 'C'])
    endif

    # Cortamos la lista según el nivel deseado
    var level = g:org_todo_priorities_level
    g:org_priorities_list = all_kinds[: level - 1]
    g:org_priorities_list_verified = true
enddef

# --- 2. Función Principal (Buscador) ---
export def Todo_Prioritie_Search(fw: bool)
    var line_todo_num = search('^\*\{1,\} ', 'nbW')
    if line_todo_num <= 0 | return | endif

    # 1. Aseguramos que las listas existan antes de usarlas
    # Si g:org_priorities_list_verified no existe, devuelve 'false'
    if !get(g:, 'org_priorities_list_verified', false)
        Todo_priorities_defaults()
    endif

    var content = getline(line_todo_num)
    var words = split(content)
    
    # 2. Obtenemos la lista de TODOs de forma segura
    var todo_list = get(g:, 'org_todo_list', ['TODO', 'DONE'])
    
    # 3. Verificamos si la línea tiene un TODO válido
    if len(words) < 2 || index(todo_list, words[1]) < 0
        return
    endif

    # Buscamos la prioridad [#?]
    var current_prior = matchstr(content, '\[#\zs.\ze\]')

    # Acceso seguro a la lista de prioridades
    var prior_list = get(g:, 'org_priorities_list', ['A', 'B', 'C'])

    if current_prior == ''
        Todo_priorities_insert(content, line_todo_num, fw)
    else
        var idx = index(prior_list, current_prior)
        Todo_priorities_toggle_kw(content, line_todo_num, idx, fw)
    endif
enddef

# --- 3. Insertar Prioridad Nueva ---
def Todo_priorities_insert(content: string, lnum: number, fw: bool)
    var words = split(content)
    var new_p = fw ? g:org_priorities_list[0] : g:org_priorities_list[-1]
    
    # Insertamos después del Keyword (ej: TODO [#A])
    var keyword = words[1]
    var new_line = substitute(content, keyword, keyword .. ' [#' .. new_p .. ']', '')
    setline(lnum, new_line)
enddef

# --- 4. Rotar Prioridad Existente ---
def Todo_priorities_toggle_kw(content: string, lnum: number, idx: number, fw: bool)
    var next_idx: number
    var list_len = len(g:org_priorities_list)

    if fw
        next_idx = idx + 1
    else
        next_idx = idx - 1
    endif

    var new_line = ''
    # Si nos salimos del rango, eliminamos la prioridad (ciclo org-mode)
    if next_idx < 0 || next_idx >= list_len
        new_line = substitute(content, ' \?\[#.\?\]', '', '')
    else
        var char = g:org_priorities_list[next_idx]
        new_line = substitute(content, '\[#.\?\]', '[#' .. char .. ']', '')
    endif

    setline(lnum, new_line)
enddef

# export def Todo_Prioritie_Search(fw: bool) # {{{
#   var line_todo = search('^\*\{1,\} ', 'nbW')

#   if line_todo <= 0
#     return # En Vim9script, 'return' es preferible a 'finish' dentro de def
#   endif

#   var line_content: string = getline(line_todo)
#   var line_checker: list<string> = split(line_content) 

#   if index(g:org_todo_list, line_checker[ 2 : -2 ]) <= 0 ||  index(g:org_todo_list, line_checker[1]) < 0
#     return
#   endif

#   if !exists( 'g:org_priorities_list_verified' )
#     g:org_priorities_list_verified = false
#   endif

#   if !g:org_priorities_list_verified
#     Todo_priorities_defaults()
#   endif

#   var value_prior = line_checker[2][2 : -2]

#   if index(g:org_priorities_list, value_prior) < 0
#     Todo_priorities_insert()
#   else
#     Todo_priorities_toggle_kw()
#   endif
# enddef # }}}

# def Todo_priorities_defaults() # {{{
#   if !exists('g:org_todo_priorities_type')
#     g:org_todo_priorities_type = 'alphabetic'
#   endif

#   var all_kinds: list<string> = []

#   if g:org_todo_priorities_type == 'alphabetic'
#     all_kinds = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '', ] 

#   elseif g:org_todo_priorities_type == 'numerical'
#     all_kinds = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', ]

#   else

#     if exists('g:org_prior_custom')
#       all_kinds = g:org_prior_custom
#       g:org_todo_priorities_level = len(g:org_prior_custom)
#     endif

#   endif
#   if !exists('g:org_todo_priorities_level')
#     g:org_todo_priorities_level = '3'
#   endif

#   if g:org_todo_priorities_level > len( all_kinds )
#     g:org_todo_priorities_level = len( all_kinds )
#   endif

#   g:org_priorities_list = all_kinds[ : g:org_todo_priorities_level ]
#   g:org_priorities_list_verified = true

# enddef # }}}

# def Todo_priorities_toggle_kw(content: string, lnum: number, todo_list: list<string>, idx: number, fw: bool) # {{{
#   var new_idx = fw ? idx + 1 : idx - 1
#   var new_line_content = ''
#   var line_content: list<string> = split(content)
#   var prev_idx = line_content[2][ 2 : -2 ]
#   var pos_list = index( g:org_priorities_list, prev_idx )
#   var prev_todo = index( g:org_todo_list, line_content[1] )
#   var head_level = line_content[0]
#   if fw
#     new_line_content = idx == len( g:org_priorities_list ) - 1 ? '' : '[#' .. g:org_priorities_list[ idx + 1 ] .. ' ]'
#   else
#     new_line_content = idx == 0 ? '' : '[#' .. g:org_priorities_list[ idx - 1 ] .. ' ]'
#   endif
#   var subs_string = 

#   var new_part = substitute(content, line_content[1], new_line_content, '')
#   setline(lnum, new_part  )
# enddef # }}}

# def Todo_priorities_insert(content: string, lnum: number, fw: bool) # {{{
#   var split_string = split(content)
#   var new_priority = fw ? g:org_priorities_list[0] : g:org_priorities_list[-1]
#   var str_priority = '[#' .. new_priority .. ']'
#   var new_line = substitute(content,  split_string[1], split_string[1] .. ' ' .. new_priority .. ' ', ''
#   setline(lnum, new_line)
# enddef # }}}

export def Todo_checkbox() # {{{
  var curr_line = line('.')
  var line_content = getline(curr_line)

  # Mejoramos el regex para incluir [-]
  if line_content !~ '^\s*- \[[X -]\] '
    curr_line = search('^\s*- \[[X -]\] ', 'nbW')
  endif

  if curr_line <= 0
    return
  endif

  # Recargamos el contenido de la línea encontrada
  line_content = getline(curr_line)

  var header_barrier = search('^\**', 'nbW')
  if header_barrier > curr_line
    return
  endif

  # Determinamos si vamos a marcar (true) o desmarcar (false)
  # Si tiene [ ] o [-], la acción suele ser marcar como [X]
  var is_empty = (line_content =~ '^\s*- \[[ -]\] ')
  Todo_toggle_checkbox(curr_line, is_empty)
enddef
# }}}

def Todo_toggle_checkbox(line_number: number, should_fill: bool) # {{{
  var line_content = getline(line_number)
  var nw_content = ''

  if should_fill
    # Si es [ ] o [-], lo convertimos en [X]
    nw_content = substitute(line_content, '\[[ -]\]', '[X]', '')
    setline(line_number, nw_content)
    # Opcional: Si marcamos un padre, llenamos los hijos
    Todo_checkbox_fill_childs(line_number, '[X]')
  else
    # Si ya estaba en [X], lo vaciamos a [ ]
    nw_content = substitute(line_content, '\[X\]', '[ ]', '')
    setline(line_number, nw_content)
    Todo_checkbox_fill_childs(line_number, '[ ]')
  endif
enddef
# }}}

def Todo_checkbox_fill_childs(line_number: number, mark_use: string) # {{{
  var parent_indent = indent(line_number)
  var i = line_number + 1
  var end_doc = line('$')

  while i <= end_doc
    var line_content = getline(i)
    var current_indent = indent(i)

    # 1. Si encontramos un header de Org, salimos
    if line_content =~ '^\*'
      break
    endif

    # 2. Si la línea está vacía, saltamos pero seguimos buscando
    if line_content =~ '^\s*$'
      i += 1
      continue
    endif

    # 3. CRÍTICO: Si la indentación es menor o igual a la del padre, 
    # significa que salimos del bloque de hijos.
    if current_indent <= parent_indent
      break
    endif

    # 4. Si es un checkbox, lo marcamos como [X]
    if line_content =~ '^\s*- \[[ X-]\] '
      var new_line = substitute(line_content, '\[[ X-]\]', mark_use, '')
      setline(i, new_line)
    endif
    i += 1
  endwhile
enddef
# }}}
