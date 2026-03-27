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
    vim.Function('search')('[[')


def Search_Header_Up():
    import vim
    srch = vim.Function('search')
    srch('^*', 'bW')


def Search_Header_Down():
    import vim
    srch = vim.Function('search')
    srch('^*', 'W')


def search_starter():
    import vim
    commnds = [
               'OrgSearchLinkPrev py3 searchingbuffer.Search_Link_Up()',
               'OrgSearchLinkNext py3 searchingbuffer.Search_Link_Down()',
               'OrgSearchHeadPrev py3 searchingbuffer.Search_Header_Up()',
               'OrgSearchHeadNext py3 searchingbuffer.Search_Header_Down()'
            ]
    mppings = [
            '<leader>ln :OrgSearchLinkNext<CR>',
            '<leader>lp :OrgSearchLinkPrev<CR>',
            '<leader>hn :OrgSearchHeadNext<CR>',
            '<leader>hp :OrgSearchHeadPrev<CR>',
            ]
    vim.command('py3 import searchingbuffer')
    for commnd in commnds:
        vim.command('command! -buffer ' + commnd)
    for mp in mppings:
        vim.command('nnoremap <buffer><silent> ' + mp)
