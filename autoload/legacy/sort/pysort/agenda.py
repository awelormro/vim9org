def agenda_start_buffer():
    import vim
    vim.command(':10split')
    vim.command('setlocal filetype=orgagenda bufhiden=wipe')
    agenda_file_start()
    vim.command('setlocal nowrite noswapfile')


def agenda_file_start():
    import vim
    vim.current.buffer[0] = 'OrgAgenda'


def agenda_delete_task():
    pass


def agenda_add_task():
    pass


def sort_agenda_tasks():
    pass


def agenda_read_files():
    pass
