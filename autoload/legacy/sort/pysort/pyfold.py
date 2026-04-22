import vim
import re


def OrgFolding():
    lnumcons = vim.vvars['lnum']
    lnum = vim.current.buffer[lnumcons-1]
    nextline = vim.current.buffer[lnumcons]
    global ntcodeblockcheap
    if re.match(r'^\s*:PROPERTIES:', lnum):
        return 'a7'
    if re.match(r'^\s*:END:', lnum):
        return "s7"
    if re.match(r'^\s*#\+BEGIN_SRC', lnum):
        ntcodeblockcheap = False
        return "a7"
    if re.match(r'^\s*#\+BEGIN', lnum):
        return "a7"
    if re.match(r'^\s*#\+END_SRC', lnum):
        ntcodeblockcheap = True
        return "s7"
    if re.match(r'^\s*#\+END', lnum):
        return "s7"
    if re.match(r'#.*\{\{\{', lnum):
        return "a7"
    if re.match(r'# \}\}\}', lnum):
        return "s7"
    if re.match(r'^\*+ ', lnum) and ntcodeblockcheap:
        return ">" + str(lnum.find(' '))
    if re.match(r'^.+$', lnum) and re.match(r'^=+$', nextline) \
            and ntcodeblockcheap:
        return ">1"
    if re.match(r'^.+$', lnum) and re.match(r'^-+$', nextline) \
            and ntcodeblockcheap:
        return ">2"
    return "="


def NtcodeblockPy(x):
    res = f"synIDattr(synID({x}, 1, 1), 'name') !=# 'OrgCodeBlock'"
    result = vim.eval(res)
    return result
