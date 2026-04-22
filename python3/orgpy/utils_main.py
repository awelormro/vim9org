import vim
import re
import json


def read_info_json(fname: str) -> None:
    pass


def generate_zip_file():
    pass


def search_v(patt: str, flags: str) -> int:
    b = vim.current.buffer[:]
    len_buffer = len(b)
    pos = vim.current.window.cursor  # row, col
    patt_exp = re.compile(patt)
    i = pos[1]
    default_opts = 'wB'
    ret_pos = [-1, -1]
    while i < len_buffer:
        if patt_exp.match(b[i]):
            ret_pos[1] = i
            break
        i += 1
    if ret_pos != -1:
        return ret_pos
    if 'w' in default_opts:
        i = pos[1]
    while i > 0:
        if patt_exp.match(b[i]):
            ret_pos[1] = i
            i -= 1
            break
    if ret_pos != -1:
