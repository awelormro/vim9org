# ✅ Así late el corazón de Vim
import vim
import re
from typing import List, Tuple, Optional


# Constantes al inicio (fáciles de modificar)
SRC_PATTERN = re.compile(r'^\s*#\+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]\b')
END_PATTERN = re.compile(r'^\s*#\+[Ee][Nn][Dd]_[Ss][Rr][Cc]\b')
src_str_vim = '^\\s*#+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc]'
end_src_str_vim = '^\\s*#+[Ee][Nn][Dd]_[Ss][Rr][Cc]'

EXTENSIONS = {
    'python': 'py', 'cpp': 'cpp', 'haskell': 'hs', 'c': 'c',
    'latex': 'tex', 'html': 'html', 'java': 'java',
    'javascript': 'js', 'vim': 'vim', 'lisp': 'lisp',
    'rust': 'rs', 'go': 'go', 'zig': 'zig', 'org': 'org'
}

# =================================================================
# Funciones principales Tangle (en orden de uso, de arriba a abajo)
# =================================================================


def tangle_full_file() -> None:
    """Tangle todos los bloques src del archivo"""
    blocks = _find_all_tangle_blocks()
    if not blocks:
        return

    files = _group_blocks_by_filename(blocks)
    _write_files(files)


def tangle_current_block() -> None:
    """Tangle solo el bloque donde está el cursor"""
    block = _find_current_tangle_block()
    if block:
        _write_file(block['filename'], block['content'])

# ============================================================
# Funciones helper (privadas con _)
# ============================================================


def _find_all_tangle_blocks() -> List[dict]:
    """Retorna lista de bloques con :tangle"""
    open_lines, close_lines = _find_all_src_blocks()
    blocks = []

    for start, end in zip(open_lines, close_lines):
        header = vim.current.buffer[start]
        filename = _extract_tangle_filename(header)

        if filename:
            blocks.append({
                'filename': filename,
                'content': vim.current.buffer[start+1:end],
                'start': start,
                'end': end
            })

    return blocks


def _find_all_src_blocks() -> Tuple[List[int], List[int]]:
    """Encuentra todos los pares begin/end src"""
    open_lines = []
    close_lines = []

    for i, line in enumerate(vim.current.buffer):
        if SRC_PATTERN.search(line):
            open_lines.append(i)
        elif END_PATTERN.search(line):
            close_lines.append(i)

    if len(open_lines) != len(close_lines):
        print("Error: Bloques src desbalanceados")
        return [], []

    return open_lines, close_lines


def _find_current_tangle_block() -> Optional[dict]:
    """Encuentra el bloque src donde está el cursor"""
    current_line = vim.current.window.cursor[0] - 1  # Vim es 1-based

    open_lines, close_lines = _find_all_src_blocks()

    for start, end in zip(open_lines, close_lines):
        if start <= current_line <= end:
            header = vim.current.buffer[start]
            filename = _extract_tangle_filename(header)

            if filename:
                return {
                    'filename': filename,
                    'content': vim.current.buffer[start+1:end]
                }
    return None


def _extract_tangle_filename(header: str) -> Optional[str]:
    """Extrae el nombre del archivo de :tangle"""
    parts = header.split()

    # Formato: #+begin_src lang :tangle filename
    if len(parts) < 4 or ':tangle' not in parts:
        return None

    tangle_idx = parts.index(':tangle')
    if tangle_idx + 1 >= len(parts):
        return None

    filename = parts[tangle_idx + 1]

    # Quitar comillas si están
    if filename.startswith('"') and filename.endswith('"'):
        filename = filename[1:-1]

    # Si es "yes", usar nombre por defecto
    if filename == 'yes':
        lang = parts[1] if len(parts) > 1 else 'txt'
        base = vim.Function('expand')('%:r')
        ext = EXTENSIONS.get(lang, 'txt')
        filename = f"{base}.{ext}"

    return filename


def _group_blocks_by_filename(blocks: List[dict]) -> dict:
    """Agrupa contenido por nombre de archivo"""
    files = {}

    for block in blocks:
        filename = block['filename']
        content = block['content']

        if filename in files:
            files[filename].extend(content)
        else:
            files[filename] = content

    return files


def _write_files(files: dict) -> None:
    """Escribe los archivos en disco"""
    for filename, content in files.items():
        vim.Function('writefile')(content, filename)
        print(f"✓ Tangled: {filename}")


def _write_file(filename, content) -> None:
    """Escribe los archivos en disco"""
    vim.Function('writefile')(content, filename)
    print(f"✓ Tangled: {filename}")


# ====================================================================
# Narrow: El poder extraer un tramo del código, modificarlo y regresar
# ====================================================================

def narrow_block() -> None:
    block = _find_current_narrow_block_src()
    if block:
        _open_buffer_narrow(block)


def narrow_tree() -> None:
    block = _find_current_narrow_block_tree()
    if block:
        _open_buffer_org_narrow(block)


def narrow_paragraph() -> None:
    block = _find_current_narrow_block_para()
    if block:
        _open_buffer_org_narrow(block)


def return_narrow() -> None:
    info_buffer = vim.current.buffer[:]
    meta = vim.eval('b:data_return')
    print(meta)
    vim.command('bw!')
    vim.command('b ' + meta['buffer'])
    b_up = int(meta['border_up'])
    b_down = int(meta['border_down'])
    if meta['fifo'] != '~/.fifo.org':
        del vim.current.buffer[b_up + 1:b_down - 1]
    else:
        del vim.current.buffer[b_up - 1: b_down - 1]
    vim.current.buffer.append(info_buffer, b_up - 1)
    vim.command('call delete(expand("' + meta['fifo'] + '"))')


# ============================================================
# Funciones helper Narrow (privadas con _)
# ============================================================


def _find_current_narrow_block_para() -> list[int]:
    pos_start = vim.Function('search')('^\\s*$', 'nbW')
    if pos_start == -1:
        pos_start = 0
    pos_end = vim.Function('search')('^\\s*$', 'nW')
    if pos_end == -1:
        pos_end = len(vim.current.buffer) - 1
    return [pos_start, pos_end]


def _find_current_narrow_block_tree() -> list[int]:
    pos_start = vim.Function('search')('^\\*', 'nbW')
    if pos_start == -1:
        pos_start = 0
    pos_end = vim.Function('search')('^\\*', 'nW')
    if pos_end == -1:
        pos_end = len(vim.current.buffer) - 1
    return [pos_start, pos_end]


def _find_current_narrow_block_src() -> list[int]:
    pos_start = vim.Function('search')(src_str_vim, 'nbW') - 1
    verifier = vim.Function('search')(end_src_str_vim, 'nbW') - 1
    if pos_start == -1:
        return None
    if pos_start < verifier:
        return None
    pos_end = vim.Function('search')(end_src_str_vim, 'nW')
    verifier = vim.Function('search')(src_str_vim, 'nW')
    if verifier < pos_end and verifier > -1:
        return None
    return [pos_start, pos_end]


def _generate_fifo_name(header) -> str:
    line_splitted = vim.current.buffer[header].split()
    if len(line_splitted) < 2 or line_splitted[1] not in EXTENSIONS:
        return '~/.fifo.txt'
    return '~/.fifo.' + EXTENSIONS[line_splitted[1]]


def _open_buffer_org_narrow(borders: list[int]) -> None:
    content_narrow = vim.current.buffer[borders[0] - 1:borders[1] - 1]
    name_buf_prev = vim.eval('bufname()')
    vim.command('e ~/.fifo.org')
    vim.current.buffer[:] = content_narrow
    vim.current.buffer.vars['data_return'] = {
            'buffer': name_buf_prev,
            'border_up': borders[0],
            'border_down': borders[1],
            'fifo': '~/.fifo.org'
            }
    vim.command('py3 import orgpy.tangle_verified as tangle')
    vim.command('command! -buffer OrgReturn :py3 tangle.return_narrow()')
    vim.command('nnoremap <buffer> q :OrgReturn<CR>')
    vim.command('setlocal bufhidden=wipe')
    print('narrow_complete')


def _open_buffer_narrow(borders: list[int]) -> None:
    name_fifo = _generate_fifo_name(borders[0])
    content_narrow = vim.current.buffer[borders[0] + 1:borders[1] - 1]
    name_buf_prev = vim.eval('bufname()')
    vim.command('e ' + name_fifo)
    vim.current.buffer[:] = content_narrow
    vim.current.buffer.vars['data_return'] = {
            'buffer': name_buf_prev,
            'border_up': borders[0],
            'border_down': borders[1],
            'fifo': name_fifo
            }
    vim.command('py3 import orgpy.tangle_verified as tangle')
    vim.command('command! -buffer OrgReturn :py3 tangle.return_narrow()')
    vim.command('nnoremap <buffer> q :OrgReturn<CR>')
    vim.command('setlocal bufhidden=wipe')
    print('narrow_complete')
