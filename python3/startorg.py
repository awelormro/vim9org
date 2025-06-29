

def start_org():
    import vim
    from narrow import narrow_generate
    from searchingbuffer import search_starter
    narrow_generate()
    search_starter()
    vim.command('py3 import checklists')
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
