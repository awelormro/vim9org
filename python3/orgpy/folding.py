import vim
import re


def fold_cache_py3():
    vb = vim.current.buffer.vars
    if 'lasttick' not in vb:
        vb['lasttick'] = vb['changedtick']
        generate_cache_fold()
        return vb['foldlevels'][vim.vvars['lnum'] - 1]
    if vb['lasttick'] == vb['changedtick']:
        return vb['foldlevels'][vim.vvars['lnum'] - 1]
    generate_cache_fold()
    return vb['foldlevles'][vim.vvars['lnum'] - 1]


def generate_cache_fold():
    vb = vim.current.buffer.vars
    vb['lasttick'] = vb['changedtick']
    foldlevels = []
    whole_buffer = vim.current.buffer[:]
    len_buffer = len(whole_buffer)
    i = 0
    max_positive = 0
    header_preamble = True
    preamble_type = re.compile(r'#\+\w*')
    head_start = re.compile(r'^(\*+)\s')
    src_start = re.compile(r'^\s*#\+[Bb][Ee][Gg][Ii][Nn]_')
    src_end = re.compile(r'^\s*#\+[Ee][Nn][Dd]_')
    pr_start = re.compile(r'^\s*:PROPERTIES:')
    pr_end = re.compile(r'^\s*:END:')
    br_start = re.compile(r'.*{{{\s*$')
    br_end = re.compile(r'.*}}}\s*$')
    while i < len_buffer:
        if head_start.match(whole_buffer[i]):
            header_preamble = False
            depth = len(head_start.match(whole_buffer[i]).group(1))
            max_positive = depth
            str_go = f'>{depth}'
            foldlevels.append(str_go)
        elif preamble_type.match(whole_buffer[i]) and header_preamble:
            foldlevels.append(8)
        elif src_start.match(whole_buffer[i]):
            max_positive += 1
            str_go = '>' + str(max_positive)
            foldlevels.append(str_go)
        elif pr_start.match(whole_buffer[i]):
            max_positive += 1
            str_go = '>' + str(max_positive)
            foldlevels.append(str_go)
        elif br_start.match(whole_buffer[i]):
            max_positive += 1
            str_go = '>' + str(max_positive)
            foldlevels.append(str_go)
        elif src_end.match(whole_buffer[i]):
            str_go = '<' + str(max_positive)
            foldlevels.append(str_go)
            max_positive -= 1
        elif pr_end.match(whole_buffer[i]):
            str_go = '<' + str(max_positive)
            foldlevels.append(str_go)
            max_positive -= 1
        elif br_end.match(whole_buffer[i]):
            str_go = '<' + str(max_positive)
            foldlevels.append(str_go)
            max_positive -= 1
        else:
            foldlevels.append(max_positive)
        i += 1
    vb['foldlevels'] = foldlevels


def folding_py3():
    import vim
    import re
    line_folding = vim.vvars['lnum']
    depth_line = vim.Function('getline')(line_folding).decode('utf-8')
    mtch = re.match(r'^(\*+)\s', depth_line)
    if mtch:
        depth = len(mtch.group(1))
        return f'>{depth}'
    mtch = re.match(r'^\s*#\+[Bb][Ee][Gg][Ii][Nn]_', depth_line)
    if mtch:
        return 'a1'
    mtch = re.match(r'^\s*:PROPERTIES:', depth_line)
    if mtch:
        return 'a1'
    mtch = re.match(r'.*{{{\s*$', depth_line)
    if mtch:
        return 'a1'
    mtch = re.match(r'^\s*:END:', depth_line)
    if mtch:
        return 's1'
    mtch = re.match(r'^\s*#\+[Ee][Nn][Dd]_', depth_line)
    if mtch:
        return 's1'
    mtch = re.match(r'.*}}}\s*$', depth_line)
    if mtch:
        return 's1'
    return '='
