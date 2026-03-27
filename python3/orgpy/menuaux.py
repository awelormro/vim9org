import vim
import re


def draw_new_menu(values_list: list):
    # Nuevo buffer
    vim.command('belowright 11new')
    list_options = ['set filetype=orgmenu']
    for opt in list_options:
        vim.command(opt)
    # Generar el encabezado
    vim.current.buffer[0] = 'Search: '
    if len(values_list) <= 10:
        vim.current.buffer.append(0, list_options)
        vim.current.buffer.vars['complete_options'] = list_options
        vim.current.buffer.vars['list_options'] = list_options
    else:
        vim.current.buffer.append(0,list_options)
        vim.current.buffer.vars['complete_options'] = list_options
        vim.current.buffer.vars['list_options'] = list_options[0:10]
    vim.current.buffer.vars['counter'] = 0
    vim.current.buffer[1] = '>' + vim.current.buffer[1]


def move_cursor_below():
    pos_search: int = vim.Function('search')('^>')
    if pos_search == -1:
        if len(vim.current.buffer) < 2:
            print('not a list, abort')
    else:
        if pos_search == 1:
            if vim.current.buffer.vars['counter'] == 0:
                if vim.current.buffer.vars == False:
                    return


def move_cursor_empty():
    if (len(vim.current.buffer.vars['complete_values']) == len(
        )
