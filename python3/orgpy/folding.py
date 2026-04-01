

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
    mtch = re.match(r'.*{{{$', depth_line)
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


