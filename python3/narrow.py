def narrow_generate():
    import vim
    vim.command('py3 import narrow')
    vim.command('command! -buffer -range OrgNarrowSection py3 narrow.narrow_buffer(<line1>, <line2>)')
    vim.command('command! -buffer OrgNarrowParagraph py3 narrow.narrow_paragraph()')
    vim.command('command! -buffer OrgNarrowTree py3 narrow.narrow_tree()')
    vim.command('command! -buffer OrgNarrowVisible py3 narrow.narrow_buffer(line("w0"), line("w$")')
    vim.command('nnoremap <buffer><silent> <leader>ons :OrgNarrowSection<CR>')
    vim.command('nnoremap <buffer><silent> <leader>onp :OrgNarrowParagraph<CR>')
    vim.command('nnoremap <buffer><silent> <leader>onv :OrgNarrowvisible<CR>')
    vim.command('vnoremap <buffer><silent> <leader>ons :OrgNarrowSection<CR>')


def narrow_paragraph():
    import vim
    up_part = vim.Function('search')("^\\s*$", 'nWb')
    down_part = vim.Function('search')("^\\s*$", 'nW')
    if up_part == 0:
        up_part = 1
    if down_part == 0:
        down_part = vim.Function('line')('$')
    narrow_buffer(up_part, down_part)


def narrow_tree():
    import vim
    import re
    up_part = vim.Function('search')("^\\*", 'nWb')
    print('searched_pos in ' + str(up_part))
    if up_part == 0:
        return
    print('header aviable')
    header_line = vim.current.buffer[up_part - 1]
    if re.search(r"^\** ", header_line):
        count_asterisks = header_line.index(" ") * "\\*"
        print('valid header')
    else:
        return
    down_part = vim.Function('search')("^"+count_asterisks+' ', 'nW')
    if down_part == 0:
        down_part = vim.Function('line')('$')
    narrow_buffer(up_part, down_part - 1)


def narrow_buffer(start, ends):
    import vim
    if hasattr(vim.vars, 'nrrow_start'):
        if vim.vars['nrrow_start'] == 1:
            error_string = 'Currently a narrowed buffer is started, finish'
            vim.command('echoerr "' + error_string + '"')
    content_narrow = vim.current.buffer[start - 1: ends]
    vim.vars['nrrow_start'] = 1
    print(content_narrow)
    buffer_add = vim.Function("expand")('%')
    # vim.command(':vsplit')
    vim.command(':e nnrow.orgnrrow')
    vim.command(':1,$delete')
    string_setlocal = 'setlocal filetype=org.orgnrrow'
    vim.command("execute \"" + string_setlocal + "\"")
    # vim.command('setlocal nowrite nobackup')
    vim.current.buffer.vars['start'] = start
    vim.current.buffer.vars['end'] = ends
    vim.current.buffer.vars['buffer_substitute'] = buffer_add
    vim.Function('append')('0', content_narrow)
    vim.command(':$delete')
    vim.Function('cursor')(1, 1)
    command_1 = 'command! -buffer OrgNarrowQuit py3 narrow.narrow_close()'
    command_2 = 'nnoremap <buffer><silent> q :OrgNarrowQuit<CR>'
    command_3 = 'inoremap <buffer><silent> <C-q> <C-o>:OrgNarrowQuit<CR>'
    vim.command(command_1)
    vim.command(command_2)
    vim.command(command_3)


def narrow_close():
    import vim
    import re
    content_file = vim.current.buffer[:]
    if len(content_file) == 1 and re.eval(r"^\s*$"):
        vim.command(':bw!')
        return
    start_replace = vim.current.buffer.vars['start']
    end_replace = vim.current.buffer.vars['end']
    replace_buffer = vim.current.buffer.vars['buffer_substitute']
    vim.command(':bw!')
    vim.command('b ' + replace_buffer.decode('utf-8'))
    vim.command(':'+str(start_replace)+','+str(end_replace)+'delete')
    vim.Function('append')(start_replace - 1, content_file)
    vim.vars['nrrow_start'] = 0
