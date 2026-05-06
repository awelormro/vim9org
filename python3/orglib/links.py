import vim
import utils


def go_link(back: bool) -> None:
    vcw = vim.current.window
    pos = vim.current.window.cursor  # row, col
    vc = vim.command
    if back:
        vc('call search("\\[\\["), "be")')
        utils.search_py("\\[\\[", "be")
        vc('call cursor(line("."), col(".")) + 1')
        if vcw.cursor[1] == pos[1] and vcw.cursor[0] == pos[0]:
            vc('call cursor(line("."), col(".")) - 2)')
            vc('call search("\\[\\["), "be")')
            vc('call cursor(line("."), col(".")) + 1')
    vc('call search("\\[\\["), "e")')
    vc('call cursor(line("."), col(".")) + 1')


def generate_link():
    name_link = utils.vinput('link name: ')
    desc_link = utils.vinput('link_content: ')
    generated_link = '[[' + name_link + '][' + desc_link + ']]'
    utils.insert_in_position(generated_link)


def enter_link():
    pass


def _enter_command():
    pass


def _enter_file_external():
    pass


def _enter_file_buffer():
    pass
