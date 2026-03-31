import vim


def org_globals_start():
    print('start python functions')
    vim.command('py3 import orgpy.tangle_verified as tangle')
    vim.command('py3 import orgpy.links_start as links')
    vim.command('py3 import orgpy.folding as fold')
    vim.command('py3 import orgpy.todo_toggle as todo')
    vim.command('setlocal foldmethod=expr')
    vim.command("setlocal foldexpr=py3eval('fold.folding_py3()')")
    vim.command('command! -buffer OrgTangleBlock py3 tangle.tangle_current_block()')
    vim.command('command! -buffer OrgNarrowBlock py3 tangle.narrow_block()')
    vim.command('command! -buffer OrgNarrowParagraph py3 tangle.narrow_paragraph()')
    vim.command('command! -buffer OrgNarrowTree py3 tangle.narrow_tree()')
    vim.command('command! -buffer OrgTODOFw py3 todo.toggle_todo(True)')
    vim.command('command! -buffer OrgTODOBw py3 todo.toggle_todo(False)')
    vim.command('command! -buffer OrgTangleFile py3 tangle.tangle_full_file()')
    vim.command('nnoremap <buffer> <Leader>ot :OrgTangleBlock<CR>')
    vim.command('nnoremap <buffer> <Leader>on :OrgNarrowBlock<CR>')
    vim.command('nnoremap <buffer> <Leader>o<Leader>t :OrgTangleFile<CR>')


def org_commands_start():
    pass
