import vim
import re


# recuerda que con type se extrae usando type(cosa).__name__


def check_link_org():
    ln = vim.current.line
    pos = vim.current.window.cursor
    link_pos = check_link(ln, pos)
    if type(link_pos).__name__ == 'int':
        return


def check_link(ln: str, pos: int):
    border_left = '[['
    border_right = ']]'
    verify_left = vim.Function('strridx')(ln, border_left, pos[1])
    if verify_left == -1:
        return verify_left
    verify_right = vim.Function('stridx')(ln, border_right, pos[1])
    if verify_right == -1:
        return verify_right
    return ln[verify_left, verify_right]


def link_type(link: str):

    if re.search(r'file:**', link):
        link_command_file(link)
        return

    if re.search(r'vim:**', link):
        link_command_vs(link)
        return

    if re.search(r'python:**', link):
        link_command_python(link)
        return


def link_command_file(link: str):
    pass


def link_command_vs(link: str):
    pass


def link_command_python(link: str):
    pass
