# vim: set nospell:
# vim: set foldmethod=indent:
import vim
import re


def OrgFolding():
    lnumcons = int(vim.vvars['lnum'])
    lnum = vim.current.buffer[lnumcons-1]
    nextline = vim.current.buffer[lnumcons]
    global ntcodeblockcheap
    if re.match(r'^\s*:PROPERTIES:', lnum):
        return 'a7'
    elif re.match(r'^\s*:END:', lnum):
        return "s7"
    elif re.match(r'^\s*#\+BEGIN_SRC', lnum):
        ntcodeblockcheap = False
        return "a7"
    elif re.match(r'^\s*#\+BEGIN', lnum):
        return "a7"
    elif re.match(r'^\s*#\+END_SRC', lnum):
        ntcodeblockcheap = True
        return "s7"
    elif re.match(r'^\s*#\+END', lnum):
        return "s7"
    elif re.match(r'#.*\{\{\{', lnum):
        return "a7"
    elif re.match(r'# \}\}\}', lnum):
        return "s7"
    elif re.match(r'^\*+ ', lnum) and ntcodeblockcheap:
        return ">" + str(lnum.find(' ')) 
    elif re.match(r'^.+$', lnum) and re.match(r'^=+$', nextline) and ntcodeblockcheap:
        return ">1"
    elif re.match(r'^.+$', lnum) and re.match(r'^-+$', nextline) and ntcodeblockcheap:
        return ">2"
    else:
        return "="


def NtcodeblockPy(x):
    result = vim.eval(f"synIDattr(synID({x}, 1, 1), 'name') !=# 'OrgCodeBlock'")
    return result=='1'
