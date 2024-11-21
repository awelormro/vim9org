# vim: set foldmethod=indent:
import vim
import re
import utils.commandextend as comext

def RestoreHeaderLevel():
    global actualheader
    linenum = int(vim.eval("line('.')"))
    while linenum > 0:
        if vim.current.buffer[linenum].startswith('*'):
            if vim.current.buffer[linenum].startswith('* '):
                actualheader = 2
            elif vim.current.buffer[linenum].startswith('** '):
                actualheader = 3
            elif vim.current.buffer[linenum].startswith('*** '):
                actualheader = 4
            elif vim.current.buffer[linenum].startswith('**** '):
                actualheader = 5
            elif vim.current.buffer[linenum].startswith('***** '):
                actualheader = 6
            break
        else:
            linenum -= 1
    if linenum == 0:
        actualheader = 0


def CommandsHeads():
    command_list = [ 
                    ['OrgRestoreHeader',    'indenting', 'RestoreHeaderLevel()'], 
                    ]
    comext.OrgCommandBuffer( command_list )


def SetHeadersSettings():
    CommandsHeads()


def IndentVimWithPython():
    global actualheader
    global kindvlnum
    lcontent = vim.eval('getline(v:lnum-1)')
    # kindvlnum=vim.vvars['lnum']
    kindvlnum = int(vim.eval('v:lnum'))
    # print(type(lcontentprev))
    if lcontent.lstrip().startswith('- ['):
        return len(lcontent) - len(lcontent.lstrip()) + 5
    elif re.match(r'^[ \t]*$', lcontent):
        return actualheader
    elif lcontent.lstrip().startswith('-'):
        return len(lcontent) - len(lcontent.lstrip()) + 2
    elif lcontent.lstrip().startswith('* '):
        actualheader = 2
        return 2
    elif lcontent.startswith('** '):
        actualheader = 3
        return 3
    elif lcontent.startswith('*** '):
        actualheader = 4
        return 4
    elif lcontent.startswith('**** '):
        actualheader = 5
        return 5
    elif lcontent.startswith('***** '):
        actualheader = 6
        return 6
    elif re.match(r'^\s*+\d*[\.\)] ', lcontent):
        return int(vim.eval('indent(v:lnum-1)'))+lcontent.lstrip().index(' ') +1
    elif re.match(r'^\s*+[a-zA-Z][\.\)] ', lcontent):
        return int(vim.eval('indent(v:lnum-1)'))+lcontent.lstrip().index(' ') +1
    elif re.match(r'^\s*[a-zA-Z0-9:]', lcontent):
        return int(vim.eval('indent(getline(v:lnum-1))'))
    elif re.match(r'^[a-zA-Z0-9:#]', lcontent):
        return 0
    else:
        return actualheader
