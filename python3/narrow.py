import vim
import re


def narrow_buffer(start, end):
    if hasattr(vim.vars, 'nrrow_start'):
        if vim.vars['nrrow_start'] is True:
            error_string = 'Currently a narrowed buffer is started, finish'
            vim.command('echoerr "' . error_string .'"')
    content_narrow = vim.current.buffer[start - 1: end - 1]
    buffer_add = vim.Function("expand")('%')
    curr_filetype = vim.eval('&filetype')
    vim.command(':enew')
    string_setlocal = 'setlocal filetype=org.orgnrrow'
    vim.command("execute \"" . string_setlocal . "\"")
    vim.current.buffer.vars['start'] = start
    vim.current.buffer.vars['end'] = end
    vim.current.buffer.vars['']
    vim.command('append')('0', content_narrow)
    vim.command('cursor')(1, 1)


def narrow_close():
    content_file = vim.current.buffer[:]
    if len(content_file) == 1 and re.eval(r"^\s*$"):
        return
    start_replace = vim.current.buffer.vars['start']
    end_replace = vim.current.buffer.vars['end']
    replace_buffer = vim.current.buffer.vars['buffer_replace_name']
