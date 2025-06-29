def tangle_start():
    pass


def tangle_buffer():
    pass


def tangle_block_position(tangle_kind):
    import vim
    search_tangle_start = vim.Function('search')('^\\s*#+BEGIN_SRC', 'nbW')
    search_tangle_end = vim.Function('search')('^\\s*#+END_SRC', 'nW')
    currline = vim.current.window.cursor
    if currline[0] >= search_tangle_start and (currline[0] <= search_tangle_end):
        tangle_generate(search_tangle_start, search_tangle_end, tangle_kind)


def tangle_generate(start_line, end_line, tangle_kind):
    import vim
    import re
    vim_pos = vim.current.buffer[start_line - 1: end_line]
    if re.search(r":tangle ", vim_pos[0]):
        tangle_content = vim_pos.split()
        tangle_pos_name = tangle_content.find(':tangle')

        if tangle_pos_name == len(tangle_content) - 1:
            tangle_name_pre = vim.command('expand')('%:r').decode('utf-8')[:-2]
            code_kind = tangle_content[1]
            tangle_name = tangle_name_generate(tangle_name_pre, code_kind)
        else:
            tangle_name = tangle_content[tangle_pos_name + 1]

        if tangle_kind == 'append':
            vim.Function('writefile')(vim_pos, tangle_name, 'a')
        elif tangle_kind == 'replace':
            vim.Function('writefile')(vim_pos, tangle_name)


def tangle_name_generate(name_file_list, code_kind):
    if name_file_list[1] == 'python':
        return name_file_list + '.py'
    elif name_file_list[1] == 'latex':
        return name_file_list + '.tex'
    elif name_file_list[1] == 'matplotlib':
        return name_file_list + '.py'
    else:
        return name_file_list + '.' + code_kind
    pass


def tangle_parts():
    pass
