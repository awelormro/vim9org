# vim: set nospell:
# vim: set foldmethod=indent:
import vim
import re

def NtcodeblockPy(x):
    result = vim.eval(f"synIDattr(synID({x}, 1, 1), 'name') !=# 'OrgCodeBlock'")
    return result=='1'


  # function! Ntcodeblock(x)
  #   return synIDattr(synID(a:x, 1, 1), 'name') !=# 'OrgCodeBlock'
  # endfunction

def OrgFolding():
    ntcodeblockcheap = True if vim.command('let b:codesection=0') == 1 else False
    lnum = vim.eval('getline(v:lnum)')
    vlnum = vim.eval('v:lnum')
    nextline = vim.eval('getline(v:lnum + 1)')
    line = vim.eval('getline(v:lnum)')
    lc = vim.eval('v:lnum')
    isnotcb = vim.eval('Ntcodeblock(v:lnum)')
    isnotcbnl = vim.eval('Ntcodeblock(v:lnum+1)')
    if re.match(r'^\s*:PROPERTIES:', lnum):
        return 'a7'
    elif re.match(r'^\s*:END:', lnum):
        return "s7"
    elif re.match(r'^\s*#\+BEGIN_SRC', lnum):
        # vim.command('let b:codesection=1')
        ntcodeblockcheap = True
        # print(vim.eval('b:codesection'))
        return "a7"
    elif re.match(r'^\s*#\+BEGIN', lnum):
        return "a7"
    elif re.match(r'^\s*#\+END_SRC', lnum):
        ntcodeblockcheap = False
        # vim.command('let b:codesection=0')
        # print(vim.eval('b:codesection'))
        return "s7"
    elif re.match(r'^\s*#\+END', lnum):
        return "s7"
        # elif re.match(r'^\*+ ', lnum) and isnotcb:
    elif re.match(r'^\*+ ', lnum) and ntcodeblockcheap:
        return ">" + str(lnum.find(' ')) 
        # elif re.match(r'^.+$', lnum) and re.match(r'^=+$', nextline) and isnotcbnl:
    elif re.match(r'^.+$', lnum) and re.match(r'^=+$', nextline) and ntcodeblockcheap:
        return ">1"
        # elif re.match(r'^.+$', lnum) and re.match(r'^-+$', nextline) and isnotcbnl:
    elif re.match(r'^.+$', lnum) and re.match(r'^-+$', nextline) and ntcodeblockcheap:
        return ">2"
    else:
        return "="


    # elif re.match(r'^\s*# \{\{\{$', lnum):
    #     return 'a7'
    # elif re.match(r'^\s*# \}\}\}$', lnum):
    #     return 's7'
#   if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
#     return ">" .. match(line, ' ')
#   endif
#   if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
#     return ">1"
#   endif 
#   if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
#     return ">2"
    # elif re.match(r'^\s*#.*\{\{\{$', lnum):
    #     return 'a7'
    # elif re.match(r'^\s*#.*\}\}\}$', lnum):
    #     return 's7'
    # isnotcb = vim.eval('Ntcodeblock(v:lnum)')
    # isnotcbnl = vim.eval('Ntcodeblock(v:lnum + 1)')
    # isnotcb = NtcodeblockPy(vlnum)
    # isnotcbnl = NtcodeblockPy(vlnum+1)

def org_folding(line_num):
    line = vim.eval(f"getline({line_num})")
    next_line = vim.eval(f"getline({line_num} + 1)")
    if line.startswith(":PROPERTIES:") and line.isspace():
        return "a7"
    elif line.strip() == ":END:":
        return "s7"
    elif line.startswith("#+BEGIN_"):
        return "a7"
    elif line.startswith("#+END_"):
        return "s7"
    elif " {{" in line:
        return "a7"
    elif " }}}" in line:
        return "s7"
    elif line.startswith('*') and 'OrgCodeBlock' not in vim.eval(f"synIDattr(synID({line_num}, 1, 1), 'name')"):
        return ">" + str(line.find(' '))
    elif line and next_line == '=' * len(next_line) and 'OrgCodeBlock' not in vim.eval(f"synIDattr(synID({line_num} + 1, 1, 1), 'name')"):
        return ">1"
    elif line and next_line == '-' * len(next_line) and 'OrgCodeBlock' not in vim.eval(f"synIDattr(synID({line_num} + 1, 1, 1), 'name')"):
        return ">2"
    return "="



# {{{ 
# def OrgFold9s(lnum: number): string
#   # echo 1
#   var Ntcodeblock = (x) => synIDattr(synID(x, 1, 1), 'name') !=# 'OrgCodeBlock'
#   var line = getline(v:lnum)
#   var lnum_end = -10
#   var nextline = getline(v:lnum + 1)
#   if line =~# '^\s*:PROPERTIES:$'
#     return "a7"
#   elseif line =~# '^\s*:END:$'
#     return 's7'
#   elseif line =~# "#+BEGIN_"
#     return "a7"
#   elseif line =~# "#+END_"
#     return "s7"
#   elseif line =~# " {{{"
#     return "a7"
#   elseif line =~# " }}}"
#     return "s7"
#   endif
#   if line =~# '^\*\+ ' && Ntcodeblock(v:lnum)
#     return ">" .. match(line, ' ')
#   endif
#   if (line =~ '^.\+$') && (nextline =~ '^=\+$') && Ntcodeblock(v:lnum + 1)
#     return ">1"
#   endif 
#   if (line =~ '^.\+$') && (nextline =~ '^-\+$') && Ntcodeblock(v:lnum + 1)
#     return ">2"
#   endif
#   return "="
# enddef # }}}
