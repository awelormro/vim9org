import vim
import re


def search_todo(bw: bool):
    if bw:
        vim.Function('search')('^*', 'b')
    else:
        vim.Function('search')('^*')


def read_todo_word(fw: bool):
    line_header = vim.Function('search')('^*', 'b')
    line_content = vim.current.buffer[line_header - 1]
    line_splitted = line_content.split()
    if 'org_todo_keywords' not in vim.vars:
        vim.vars['org_todo_keywords'] = ['TODO', 'DOING', 'DONE', '']
    if line_splitted[1] not in vim.vars['org_todo_keywords']:
        return


def todo_toggle_keyword(bw: bool):
    pass
