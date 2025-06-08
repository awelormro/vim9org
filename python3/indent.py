def PyindentOrg():
    import vim
    mode = vim.Function("mode")
    exists = vim.Function("exists")
    curr_line = vim.vvars['lnum']
    print(curr_line)
    if mode() == b'i' and exists('b:fold_cache_enabled') and vim.vars['']:
        vim.current.buffer(curr_line)
