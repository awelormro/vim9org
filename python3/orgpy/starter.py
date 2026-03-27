import vim


def org_globals_start():
    print('start python functions')
    vim.command('py3 import orgpy.tangle as tangle')
    vim.command('py3 import orgpy.links_start as links')
    vim.command('command! -buffer OrgTangleBlock py3 tangle.tangle_basic()')
    vim.command('command! -buffer OrgNarrowBlock py3 tangle.narrow_block()')
    vim.command('command! -buffer OrgTangleFile py3 tangle.generate_file_complete_tangle()')
    vim.command('nnoremap <buffer> <Leader>ot :OrgTangleBlock<CR>')
    vim.command('nnoremap <buffer> <Leader>on :OrgNarrowBlock<CR>')
    vim.command('nnoremap <buffer> <Leader>o<Leader>t :OrgTangleFile<CR>')


def org_commands_start():
    pass
