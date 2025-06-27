def PyindentOrg():
    import vim
    import re
    lnum = vim.vvars['lnum']
    pnonblank = vim.Function('prevnonblank')(lnum - 1)
    if pnonblank == 0:
        return 0

    pline = vim.current.buffer[pnonblank - 1]
    level = vim.Function('indent')(pnonblank)

    if re.search(r"^\*{1,6} ", pline):
        return pline.index(' ') + 1

    elif re.search(r"^\s*-", pline):
        return level + 2
    elif re.search(r"^\s*\d*[\.\)]", pline):
        return pline.index(' ') + 1

    elif re.search(r"^\s*[+\*] ", pline):
        return level + 2

    # return len(pline) - len(pline.lstrip())
    return level
