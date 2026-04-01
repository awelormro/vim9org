import vim
import re

LINK_PATH = re.compile(r'\[\[(.*?)\]\]')
FILE_PATH = re.compile(r'^[\w/\\\-\.]+\.\w+$')
EXTERNAL_FILE_PATH = re.compile(r'^file:.*')
VIM_COMMAND = re.compile(r'^vim:.*')
PY_COMMAND = re.compile(r'^python:.*')
LUA_COMMAND = re.compile(r'^lua:.*')
HTTP_PATH = re.compile(r'^https?://.*')
CUSTOM_ID_PATTERN = re.compile(r'^:CUSTOM-ID:\s+(.+)$')
HEADER_PATH = re.compile(r'^\** ')
vim.vars['external_files_open'] = [
    'docx', 'pdf', 'xls', 'xlsx', 'ppt', 'pptx',
    'mp3', 'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4a', 'flac', 'wav', 'ogg',
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp', 'ico', 'tiff', 'tif',
    'zip', 'rar', 'tar', 'gz', 'bz2', '7z', 'xz', 'zst',
    'exe', 'msi', 'appimage', 'deb', 'rpm', 'sh', 'bat', 'cmd',
    'epub', 'mobi', 'azw', 'azw3',
    'odt', 'ods', 'odp', 'odg',
    'vsd', 'vsdx', 'drawio', 'dia',
    'eml', 'msg', 'vcf', 'ics',
    'stl', 'obj', 'fbx', 'blend', 'step', 'iges',
    'ttf', 'otf', 'woff', 'woff2',
    'iso', 'img', 'dmg',
    'psd', 'ai', 'xd', 'fig', 'sketch', 'xmind', 'mmap'
]


# =======================================================
# Links: can direct to parts inside the file or external
# =======================================================
# vim.current.window.cursor es [row, col]

def links_go_next():
    vim.Function('search')('[[')


def links_go_prev():
    curr_pos = vim.current.window.cursor
    vim.Function('search')('[[', 'b')
    if curr_pos == vim.current.window.cursor:
        vim.current.window.cursor = (curr_pos[0], curr_pos[1] - 2)
        vim.Function('search')('[[', 'b')


def links_enter():
    # Verificar link si existe
    borders = _is_inside_link()
    if borders:
        _verify_link_type(borders)
    pass


# ==========================================
# Auxiliar functions
# ==========================================

def _is_inside_link():
    curr_pos = vim.current.window.cursor[1]
    line_content = vim.current.line
    check_start = line_content.rfind('[[', 0, curr_pos)
    if check_start < 0:
        if vim.current.line[curr_pos] == '[' and curr_pos > 0:
            check_start = line_content.rfind('[', 0, curr_pos)
        if check_start < 0 and curr_pos == 0:
            check_start = line_content.find('[', curr_pos)
        if check_start < 0:
            # print('not inside link')
            return None
    check_end = line_content.find(']]', curr_pos)
    if check_end < 0:
        # print('not inside link')
        return None
    if check_start <= curr_pos <= check_end:
        # print('inside link')
        return [check_start, check_end]
    return None


def _verify_link_content(borders: list[int]) -> str:
    """Obtain the link content to pass to a structure"""
    content = vim.current.line[borders[0]:borders[1]]
    if content.find('][') > -1:
        # print('link with description')
        link_content = content.split('][')[0][2:]
    else:
        # print('only link')
        if content.endswith(']]'):
            link_content = content[2:-2]
        else:
            link_content = content[2:]
    return link_content


def _verify_link_type(content: str) -> None:
    """Generates the kind of link if command, file or inside file"""
    # Buscar si existe el tag interno <<cosa>>, luego el attr, luego header y si no, lo demás
    link_content = _verify_link_content(content)
    if '~' not in link_content:
        find_head = vim.Function('search')('<<' + link_content + '>>', 'n')
        if find_head > 0:
            vim.Function('search')('<<' + link_content + '>>')
            curr_pos = vim.current.window.cursor
            vim.current.window.cursor = [curr_pos[0], curr_pos[1] + 2]
            return
        find_head = vim.Function('search')(':CUSTOM-ID:\\s' + link_content, 'n')
        if find_head > 0:
            vim.Function('search')(':CUSTOM-ID:\\s*' + link_content)
            curr_pos = vim.current.window.cursor
            vim.current.window.cursor = [curr_pos[0], curr_pos[1] + 12]
            return
        find_head = vim.Function('search')('\\**\\s' + link_content[1:] + '$', 'n')
        if find_head < 1 and link_content.startswith('*'):
            gen = vim.eval('input("header not found, Create? y/n")')
            if gen == 'y':
                vim.current.buffer.append('* ' + link_content[1:])
                return
        if find_head > 0:
            find_head = vim.Function('search')('\\**\\s' + link_content[1:] + '$')
            return
    if HTTP_PATH.match(link_content):
        vim.command('URLOpen ' + link_content)
        return
    if VIM_COMMAND.match(link_content):
        vim.command(link_content[3:])
        return
    if LUA_COMMAND.match(link_content):
        vim.command('lua ' + link_content[4:])
        return
    if PY_COMMAND.match(link_content):
        vim.command('py3 ' + link_content[7:])
    if FILE_PATH.match(link_content):
        extension_list = vim.eval('g:external_files_open')
        extension_start = link_content.rfind('.')
        print(link_content[extension_start + 1:])
        vim.vars['test_file_path'] = link_content[extension_start + 1:]
        if link_content[extension_start + 1:] not in extension_list:
            print('external file link')
            vim.command('e ' + link_content)
        else:
            vim.command('Launch xdg-open ' + link_content)
        return
