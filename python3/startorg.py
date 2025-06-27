

def start_org():
    import vim
    vim.command('py3 import narrow')
    vim.command('py3 import checklists')
    vim.command('command! -buffer -range OrgNarrowSection py3 narrow.narrow_buffer(<line1>, <line2>)')
    vim.command('command! -buffer OrgNarrowParagraph py3 narrow.narrow_paragraph()')
    vim.command('command! -buffer OrgNarrowTree py3 narrow.narrow_tree()')
    print('start vim functions')
    pass


def generate_mappings():
    pass


def generate_mapping():
    pass


def generate_commands():
    pass


def generate_command():
    pass
