def Search_Link_Up():
    import vim
    srch = vim.Function('search')
    cl = vim.Function('col')
    ln = vim.Function('line')
    curpos = vim.Function('cursor')
    line_prev = ln('.')
    col_prev = cl('.')
    cl('.')
    srch('[[', 'b')
    line_post = ln('.')
    col_post = cl('.')
    if line_prev == line_post and col_post == col_prev:
        curpos(line_post, col_post - 1)
        srch('[[', 'b')


def Search_Link_Down():
    import vim
    srch = vim.Function('search')
    srch('[[', 'b')


def Search_Header_Up():
    import vim
    srch = vim.Function('search')
    srch('^*', 'bW')


def Search_Header_Down():
    import vim
    srch = vim.Function('search')
    srch('^*', 'W')
