def create_buffer_orgspecial(list_search, header_input):
    import vim
    vim.command('11new')
    vim.command('e search.orgsearch')
    vim.Function('setline')(1, 'Buffer creado desde python')
    vim.current.buffer.vars['main_values'] = list_search
    fill_buffer_orgspecial(list_search)


def fill_buffer_orgspecial(list_search, header_input):
    import vim
    if len(vim.current.buffer.vars['search_values']) < 10:
        fill_values = vim.current.vars['search_values']
    else:
        fill_values = vim.current.buffer.vars['search_values'][:10]
    vim.Function('setline')(1, header_input)
    vim.Function('append')(1, fill_values)
    vim.current.buffer[1] = '->' . vim.current.buffer[1]


def move_cursor_up():
    import vim
    cb = vim.current.buffer
    pos_current_signal = vim.Function('search')('^->', 'n')
    if pos_current_signal == 2:
        vim.command('2,$delete')
        var_add = '->' . b.vars['search_values'][-1]
        vim.Function('append')(1, var_add)
    else:
        cb[pos_current_signal - 1] = cb[pos_current_signal - 1][2:]
        cb[pos_current_signal - 2] = '->' . cb[pos_current_signal - 2]


def move_cursor_down():
    import vim
    cb = vim.current.buffer
    pass


def search_values():
    pass
