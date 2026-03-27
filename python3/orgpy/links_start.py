import vim


def links_enter():
    # Verificar link si existe
    # Pasar parámetro su tipo y sacar su información
    # si es de tipo comando con vim, python, lua, se ejecuta el comando
    # si es de archivo no texto, se pasa a xdg-open
    # Si es de archivo texto, se verifica su extensión y se checa la línea
    pass


def links_verify_pos():
    curr_line = vim.current.line
    curr_pos = vim.current.window.cursor
    pos_link_start = curr_line.rfind('[[', 0, curr_pos[1])
    if pos_link_start < 0:
        return ''
    pos_link_end = curr_line.find(']]', curr_pos[1])
    if pos_link_end < 0:
        return ''
    return curr_line[pos_link_start:pos_link_end]


def links_go_next():
    vim.Function('search')('[[')


def links_go_prev():
    vim.Function('search')('[[', 'b')
