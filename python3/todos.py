import vim
import re


def todo_header_toggle(fw):
    vf = vim.Function
    line_todo = vf('search')('^\\*\\{1,\\} ', 'nbW')

    if line_todo <= 0:
        return

    line_content = vim.current.buffer(line_todo - 1)
    todo_list = vim.vars['org_todo_list'] if vim.vars['org_todo_list'] else ['TODO', 'DOING', 'DONE']
    parts = line_content.split()

    if len(parts) < 2:
        return

    if fw:
        Add_kw(line_content, line_todo, todo_list[0])
    else:
        Add_kw(line_content, line_todo, todo_list[0])

    current_kw = parts[1]

    idx = todo_list.find(current_kw)
    if idx == -1:
        Add_kw(line_content, line_todo, todo_list[0] if fw else todo_list[-1])
    else:
        Rotate_kw(line_content, line_todo, todo_list, idx, fw)


def Add_kw(content: str, lnum: int, kw: str):
    # '^\(\*\{1,\}\s\)' -> r'^(\*+\s)'
    # Agrega el keyword después del primer grupo de asteriscos y el espacio
    new_line = re.sub(r'^(\*+\s)', r'\1' + kw + ' ', content, count=1)
    # lnum - 1 porque los índices de lista en Python/Vim-python empiezan en 0
    vim.current.buffer[lnum - 1] = new_line


def Rotate_kw(content: str, lnum: int, todo_list: list, idx: int, fw: bool):
    new_idx = idx + 1 if fw else idx - 1
    new_line = ''

    # Patrón base para capturar los asteriscos iniciales y el espacio
    prefix_pattern = r'^(\*+\s)'
    current_kw_escaped = re.escape(todo_list[idx])

    if new_idx >= len(todo_list) or new_idx < 0:
        # EQUIVALENTE VIM9: substitute(..., todo_list[idx] .. '\s*', '\1', '')
        # Elimina el keyword y el espacio que le sigue
        pattern = prefix_pattern + current_kw_escaped + r'\s*'
        new_line = re.sub(pattern, r'\1', content, count=1)
    else:
        # EQUIVALENTE VIM9: substitute(..., todo_list[idx], '\1' .. next_kw, '')
        next_kw = todo_list[new_idx]
        pattern = prefix_pattern + current_kw_escaped
        new_line = re.sub(pattern, r'\1' + next_kw, content, count=1)

    vim.current.buffer[lnum - 1] = new_line


def todo_priorites_defaults():
    if 'org_todo_priorities_level' not in vim.vars:
        vim.vars['org_todo_priorities_level'] = 3

    all_kinds = []

    if 'org_todo_priorities_type' not in vim.vars:
        vim.vars['org_todo_priorities_type'] = 'alphabetic'
    p_type = vim.Function('get')('g:', 'org_todo_priorities_type', 'alphabetic')

    if p_type == 'alphabetic':
        all_kinds = ['A', 'B', 'C', 'D', 'E', 'F']
    elif p_type == 'numerical':
        all_kinds = ['1', '2', '3', '4', '5']
    else:
        if 'org_prior_custom' not in vim.vars:
            vim.vars['org_prior_custom'] = ['A', 'B', 'C']
            all_kinds = vim.vars['org_prior_custom']

    level = vim.vars['org_todo_priorities_level']
    vim.vars['org_priorities_list'] = all_kinds[: level - 1]
    vim.vars['org_priorities_list_verified'] = True


def todo_priorities_search(fw: bool):
    line_todo_num = vim.Function('search')('^\\*\\{1,\\} ', 'nbW')
    if line_todo_num <= 0:
        return
    if not vim.Function('get')('g:', 'org_priorities_list_verified', False):
        todo_priorites_defaults()

    content = vim.current.buffer[line_todo_num - 1]
    words = content.split()
    if 'org_todo_list' not in vim.vars:
        todo_list = ['TODO', 'DONE']
    if len(words) < 2 or todo_list.find(words[1]) < 0:
        return

    current_prior = re.match(r'\[#\S*\]', words[1])
    if current_prior:
        todo_priorities_insert(content, line_todo_num, fw)
    else:
        idx = prior_list.find(current_prior)
        todo_priorities_toggle_kw(content, line_todo_num, idx, fw)


def todo_priorities_insert(content: str, lnum: int, fw: bool):
    words = content.split()
    new_p = vim.vars['org_priorities_list'][0] if fw else vim.vars['org_priorities_list'][-1]

    keyword = words[1]
    new_line = content.replace(keyword, keyword + '[#' + new_p + ']')
    vim.current.buffer[lnum - 1] = new_line


def todo_priorities_toggle_kw(content: str, lnum: int, idx: int, fw: bool):
    list_len = len(vim.vars['org_priorities_list'])
    next_idx = idx + 1 if fw else idx - 1

    new_line = ''
    if next_idx < 0 or next_idx >= list_len:

        new_line = re.sub(r'\[#\S*\]', '', content, 1)
    else:
        char = vim.vars['org_priorities_list'][next_idx]
        new_line = re.sub(r'\[#\S*\]',
                          '[#' + char +
                          ']', content, 1)
    vim.current.buffer[lnum - 1] = new_line


def todo_checkbox():
    curr_line = vim.current.window.cursor[0]
    line_content = vim.current.line
    if re.search(r'^\s*- \[[X -]\] ', line_content):
        curr_line = vim.Function('search')('^\\s*- \\[[X -]\\] ', 'nbW')

    if curr_line <= 0:
        return

    line_content = vim.current.buffer[curr_line - 1]
    header_barrier = vim.Function('search')('^\\**', 'nbW')
    if header_barrier > curr_line:
        return
    is_empty = re.match(r'^\s*- \[[ -]\] ', curr_line)
    todo_toggle_checkbox(curr_line, is_empty)


def todo_toggle_checkbox(line_number: int, should_fill):
    pass
