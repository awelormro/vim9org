import vim
import re


def narrow_block():
    src_str_start = '#+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]'
    src_str_end = '#+[Ee][Nn][Dd]_[Ss][Rr][Cc]'

    line_borders = verify_range(src_str_start, src_str_end)
    if line_borders == [-1, -1]:
        vim.command('echo "Not inside a src block"')
        return

    name_file = vim.Function('bufname')().decode('utf-8')
    start, end = line_borders

    block_content = vim.current.buffer[start + 1:end]

    begin_line = vim.current.buffer[start]
    parts = begin_line.split()
    if len(parts) < 2:
        vim.command('echo "Invalid src block"')
        return

    lang = parts[1]
    # syntax_verifier = generate_syntax(lang)
    syntax_verifier = lang

    original_bufnr = vim.current.buffer.number
    original_cursor = vim.current.window.cursor
    syntax_extension = generate_syntax(lang)
    fifo_short = '~/.fifo.' + syntax_extension
    fifo_name = vim.Function('expand')(fifo_short).decode('utf-8')
    # vim.command('botright new')
    vim.command('e ~/.fifo.' + syntax_extension)
    # vim.command('setlocal buftype=nofile')
    vim.command('setlocal bufhidden=wipe')
    vim.command('setlocal noswapfile')
    vim.command('set filetype=' + syntax_verifier + '.narrow')

    vim.current.buffer[:] = block_content

    vim.current.buffer.vars['org_narrow_original'] = {
        'buffer': original_bufnr,
        'cursor': original_cursor,
        'start': start,
        'end': end,
        'begin_line': begin_line,
        'fifo': fifo_name
    }

    vim.command('py3 import orgpy.tangle as tangle')
    vim.command('command! -buffer OrgReturnNarrow py3 tangle.return_narrow_block()')
    vim.command('nnoremap <buffer> q :OrgReturnNarrow<CR>')
    vim.command('echo "Narrowed to src block. Press q to return"')


def return_narrow_block():
    if 'org_narrow_original' not in vim.current.buffer.vars:
        vim.command('echo "No narrow context"')
        return

    meta = vim.current.buffer.vars['org_narrow_original']
    original_bufnr = meta['buffer']
    start = meta['start']
    end = meta['end']
    new_content = vim.current.buffer[:]
    vim.command('bw!')
    vim.command('buffer ' + str(original_bufnr))
    vim.current.buffer[start + 1:end] = new_content
    vim.current.window.cursor = meta['cursor']
    vim.Function('delete')(meta['fifo'])

    vim.command('echo "Changes applied. Returned from narrow"')


# BEGIN_SRC 
# comando botright 10new te permite crear un buffer nuevo
# Para la ruta, se puede usar el getcwd de vim
def generate_syntax(ftype: str) -> str:
    filetypes = {
                 # Lenguajes de programación
                 'python': 'py',
                 'javascript': 'js',
                 'typescript': 'ts',
                 'ruby': 'rb',
                 'java': 'java',
                 'c': 'c',
                 'cpp': 'cpp',
                 'go': 'go',
                 'rust': 'rs',
                 'php': 'php',
                 'swift': 'swift',
                 'kotlin': 'kt',
                 'scala': 'scala',
                 'lua': 'lua',
                 'r': 'r',
                 'matlab': 'm',
                 'sql': 'sql',
                 # Web y marcado
                 'html': 'html',
                 'css': 'css',
                 'scss': 'scss',
                 'xml': 'xml',
                 'json': 'json',
                 'yaml': 'yaml',
                 'markdown': 'md',
                 'rst': 'rst',
                 # Scripts y shell
                 'sh': 'sh',
                 'powershell': 'ps1',
                 'perl': 'pl',
                 # Configuración
                 'toml': 'toml',
                 'dosini': 'ini',
                 # Documentos
                 'tex': 'tex',
                 'org': 'org',
                 'text': 'txt',
                 'csv': 'csv',
                 }
    if ftype not in filetypes:
        return 'txt'
    return filetypes[ftype]


def verify_tangle_name(line_start: str) -> str:
    split_name = line_start.split()
    if len(split_name) < 3:
        return
    name_tangle = split_name[3]
    if name_tangle == 'yes':
        name_file_tangle = vim.Function('expand')('%:t:r').decode('utf-8')
        syntax_kind = generate_syntax(split_name[1])
        name_file_tangle = name_file_tangle + '.' + syntax_kind
        return name_file_tangle
    name_file_tangle = split_name[3]
    if (name_file_tangle[0] == '"' and name_file_tangle[-1] == '"') or\
            (name_file_tangle[0] == "'" and name_file_tangle[-1] == "'"):
        name_file_tangle = name_file_tangle[1:-1]
    return name_file_tangle


def generate_file_complete_tangle():
    src_str_start = '#+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]'
    src_str_end = '#+[Ee][Nn][Dd]_[Ss][Rr][Cc]'
    start_lines = verify_range(src_str_start, src_str_end)
    if start_lines == [-1, -1]:
        return
    search_pattern = start_lines[0]
    buffer_nums = list(enumerate(vim.current.buffer))
    list_elements = [line for line in buffer_nums if re.match(search_pattern, line)]
    full_file = []
    i = list_elements[0][0] + 1
    counter_elements = 0
    len_elements = len(list_elements)
    len_buffer = len(vim.current.buffer)
    while i < len_buffer:
        if counter_elements + 1 == len_elements:
            break
        if re.match(r'#+[Ee][Nn][Dd]_[Ss][Rr][Cc]', vim.current.buffer[i]):
            counter_elements += 1
            i = list_elements[counter_elements]
            continue
        full_file += vim.current.buffer[i]
        i += 1
    start_block = vim.current.buffer[start_lines[0]]
    name_tangle = verify_tangle_name(start_block)
    write_file(full_file, name_tangle)


# TODO: Start massive tangle
# TODO: start logic narrow
# TODO: verify commands in vim
def verify_range(border_up: str, border_down: str) -> list:
    line_border_up = vim.Function('search')(border_up, 'nbW')
    range_verifier = vim.Function('search')(border_down, 'nbW')
    if line_border_up < range_verifier or line_border_up < 0:
        return [-1, -1]
    line_border_down = vim.Function('search')(border_down, 'nW')
    range_verifier = vim.Function('search')(border_up, 'nW')
    if line_border_down > range_verifier or line_border_down < 0:
        print('src block not has a valid footer')
        return [-1, -1]
    return [line_border_up - 1, line_border_down - 1]


def write_file(tangle_lines: list, name_tangle: str) -> None:
    curr_dir = vim.Function('getcwd')().decode('utf-8')
    curr_file_path = vim.Function('expand')('%:h').decode('utf-8')
    print(tangle_lines)
    print(name_tangle)
    if curr_dir != curr_file_path:
        vim.command('cd ' + curr_file_path)
        vim.Function('writefile')(tangle_lines, name_tangle)
        vim.command('cd ' + curr_dir)
        print('block tangled succesfully')
        return
    vim.Function('writefile')(tangle_lines, name_tangle)
    print('block tangled succesfully')


def tangle_basic() -> None:
    src_str_start = '#+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]'
    src_str_end = '#+[Ee][Nn][Dd]_[Ss][Rr][Cc]'
    line_borders = verify_range(src_str_start, src_str_end)
    print(line_borders)
    start_block = vim.current.buffer[line_borders[0]]
    print(start_block)
    if line_borders[0] == -1:
        return
    name_tangle = verify_tangle_name(start_block)
    tangle_lines = vim.current.buffer[line_borders[0] + 1:line_borders[1]]
    write_file(tangle_lines, name_tangle)


# Reemplaza tu función find_all_blocks (o añade esta)
def find_all_blocks_grouped():
    """Encuentra todos los bloques y los agrupa por nombre de archivo"""
    start_pattern = r'#\+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]'
    end_pattern = r'#\+[Ee][Nn][Dd]_[Ss][Rr][Cc]'

    blocks_by_file = {}

    i = 0
    buffer_lines = vim.current.buffer

    while i < len(buffer_lines):
        line = buffer_lines[i]

        # Buscar BEGIN_SRC
        if re.match(start_pattern, line):
            start_line = i

            # Extraer nombre del archivo usando TU función
            filename = verify_tangle_name(line)
            if not filename:
                i += 1
                continue

            # Buscar END_SRC
            j = i + 1
            found_end = False
            while j < len(buffer_lines):
                if re.match(end_pattern, buffer_lines[j]):
                    end_line = j
                    found_end = True
                    break
                j += 1

            if found_end:
                # Extraer contenido (excluyendo BEGIN y END)
                content = buffer_lines[start_line + 1:end_line]

                # Agrupar por nombre de archivo
                if filename not in blocks_by_file:
                    blocks_by_file[filename] = []
                blocks_by_file[filename].extend(content)

                # Saltar al final del bloque
                i = end_line + 1
                continue
        i += 1

    return blocks_by_file


# Reemplaza o mejora tu generate_file_complete_tangle
def generate_file_complete_tangle():
    """Tangle TODOS los bloques, concatenando los que van al mismo archivo"""
    blocks_by_file = find_all_blocks_grouped()

    if not blocks_by_file:
        vim.command('echo "No src blocks found"')
        return

    for filename, content in blocks_by_file.items():
        # Usar TU función write_file existente
        write_file(content, filename)
        vim.command(f'echo "Tangled {len(content)} lines to {filename}"')

    vim.command(f'echo "Total: {len(blocks_by_file)} files generated"')
