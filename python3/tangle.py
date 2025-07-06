def tangle_start():
    import vim
    vim.command('py3 import tangle')
    commands = [
            'OrgTangleAppendBlock py3 tangle.tangle_current("append")',
            'OrgTangleReplaceBlock py3 tangle.tangle_current("replace")',
            ]
    mappings = [
            '<leader>tab :OrgTangleAppendBlock<CR>',
            '<leader>trb :OrgTangleReplaceBlockBlock<CR>',
            ]
    for command in commands:
        vim.command('command! -buffer ' + command)
    for mapping in mappings:
        vim.command('nnoremap <silent><buffer> ' + mapping)


def tangle_current(kind):
    import vim
    currpos = vim.current.window.cursor
    print('start to verify')
    start_pos = vim.Function('search')('^\\s*#+BEGIN_SRC', 'nbW')
    verifier_start = vim.Function('search')('^\\s*#+BEGIN_SRC', 'nW')
    end_pos = vim.Function('search')('^\\s*#+END_SRC', 'nW')
    if verifier_start > end_pos:
        print('error in the current part')
        return
    if currpos[0] > end_pos or currpos[0] < start_pos:
        return
    tangle_section(start_pos, end_pos, kind)


def tangle_section(section_start, section_end, tangle_type):
    import vim
    import re
    line_start = vim.current.buffer[section_start - 1]
    line_end = vim.current.buffer[section_end - 1]
    print('start read path')
    if re.search(r"^\s*#\+BEGIN_SRC", line_start) and re.search(r"^\s*#\+END_SRC", line_end):
        print('start check parts')
        section_tangle = vim.current.buffer[section_start: section_end - 1]
        tangle_name = define_tangle_name(line_start)
        if tangle_name[1] == 'empty':
            return
        print('valid section')
        if tangle_type == 'replace':
            vim.Function('writefile')(section_tangle, tangle_name[0])
            print('saved replaced file')
        elif tangle_type == 'append':
            vim.Function('writefile')(section_tangle, tangle_name[0], 'a')
            print('saved appended file')
        else:
            vim.Function('writefile')(section_tangle, tangle_name[0], 'a')
            print('saved appended file')


def define_tangle_name(line_start):
    import vim
    data = []
    line_splitted = line_start.strip().split()
    if len(line_splitted) == 1:
        return ['', 'empty']
    i = 0
    len_split = len(line_splitted)
    idx_split = False
    while i < len_split:
        if line_splitted[i] == ':tangle':
            idx_split = True
            break
        else:
            i += 1
    if idx_split is False:
        print('not a tangle option')
        return
    if i == len(line_splitted) - 1:
        name_file_pre = vim.Function('expand')('%:r').decode('utf-8')
        if line_splitted[1] == 'matplotlib':
            extension = '.py'
        elif line_splitted[1] == 'python':
            extension = '.py'
        elif line_splitted[1] == 'markdown':
            extension = '.md'
        elif line_splitted[1] == 'yaml':
            extension = '.yml'
        elif line_splitted[1] == 'bash':
            extension = '.sh'
        elif line_splitted[1] == 'c#':
            extension = '.cs'
        elif line_splitted[1] == 'rust':
            extension = '.rs'
        elif line_splitted[1] == 'javascript':
            extension = '.js'
        elif line_splitted[1] == 'haskell':
            extension = '.hs'
        elif line_splitted[1] == 'c++':
            extension = '.cpp'
        else:
            extension = '.' + line_splitted[1]
        name_file = name_file_pre + extension
        data = [name_file, 'full']
        print('data found, file will be: ' + data[0])
        return data
    else:
        idname = i + 1
        name_file = vim.Function('expand')(line_splitted[idname]).decode('utf-8')
        return [name_file, 'full']


def tangle_buffer(kind):
    import vim
    import re
    buffer_content = vim.current.buffer[:]
    i = 0
    start_list = []
    end_list = []
    len_buffer = len(buffer_content)
    while i < len_buffer:
        if re.search(r"^\s*#\+BEGIN_SRC", buffer_content[i]):
            start_list.append(i)
        elif re.search(r"^\s*#\+END_SRC", buffer_content[i]):
            end_list.append(i)
        i += 1
    if len(start_list) != len(end_list):
        vim.command('echoerr "not valid order, please verify"')
        return
    all_files = verify_names(start_list)
    all_blocks = generate_codes(all_files, end_list)


def generate_codes(file_list, end_list):
    blocks = []
    i = 0
    len_list = len(file_list)
    while i < len_list:
        blocks.append(i)
    return blocks


def verify_names(start_list):
    import vim
    filename_list = []
    file_props = []
    data_out = []
    for elem in start_list:
        file_props = vim.current.buffer[elem].strip().split()
        if len(file_props) > 1 and ':tangle' in file_props:
            if file_props.index(':tangle') == len(file_props) - 1:
                line_data = vim.current.buffer[elem]
                name_data = define_tangle_name(line_data)
                data_out = [elem, name_data]
            else:
                prev_name = file_props.index('tangle') + 1
                name_data = vim.Function('expand')(prev_name).decode('utf-8')
                data_out = [elem, name_data]
            filename_list.append(data_out)
    return data_out
