def checklist_update_lines():
    checklist_toggle_status()
    checklist_update_lines()


def checklist_toggle_status():
    import re
    import vim
    import functions_main as fm

    # Search for the start of a checklist:
    line_curr_pos = fm.cw.cursor  # Cursor row
    vim.Function('cursor')('line(".")', 4444444)
    line_search = vim.Function('search')('^\\s*- [', 'nbW')  # search part
    print(line_search)

    if line_search == 0:
        print('not a checklist up, stop')
        fm.cursor(line_curr_pos[0], line_curr_pos[1])
        return

    fm.cursor(line_curr_pos[0], line_curr_pos[1])
    line_content = fm.cb[line_search - 1]

    # Verify if the checkbox is previous a header or a blank line
    line_header = fm.search('^\\*', 'nbW')  # Finds previous header
    if line_header > line_search:
        print('header before a checklist, stop')
        return

    line_prev_blank = fm.search('^\\s*$', 'nbW')  # Finds previous blankline
    if line_prev_blank > line_search:
        print('blankline before checklist, stop')
        return

    # If is in a valid position, substitute the task
    if re.search(r"^\s*- \[ \]", line_content):
        print('will generate substitution empty')
        new_line_content = fm.substitute(line_content,
                                         '- \\[ \\]', '- \\[X\\]', '')
        fm.setline(line_search, new_line_content)
    elif re.search(r"^\s*- \[X\]", line_content):
        print('will generate substitution full')
        new_line_content = fm.substitute(line_content,
                                         '- \\[X\\]', '- \\[ \\]', '')
        fm.setline(line_search, new_line_content)
    elif re.search(r"- \[-\]", line_content):
        print('will generate substitution partial')
        new_line_content = fm.substitute(line_content,
                                         '- \\[-\\]', '- \\[X\\]', '')
        fm.setline(line_search, new_line_content)


def checklist_update_status():
    # Check the position of the previous and next blanklines
    import functions_main as fm
    import vim
    import re

    actual_cursor_pos = [vim.Function('line')('.'), vim.Function('col')('.')]
    prev_blankline = vim.Function('search')('^\\s$', 'nWb')
    next_blankline = vim.Function('search')('^\\s$', 'nW')

    # Check the position of the previous and next headers
    prev_header = vim.Function('search')('^\\*', 'nWb')
    next_header = vim.Function('search')('^\\*', 'nW')
    # Generate a list with the line number and content of every checkbox
    i = 0
    # Count main and childs
    # Loop to substitute the positions
    pass


def test_strings():
    import re
    test_check1 = ' - [ ] cosas'
    test_check2 = ' - [X] cosas'
    test_check3 = ' - [-] Cosas'
    test_check4 = '* Cosas'
    if re.search(r"^\s*- \[ \]", test_check1):
        print('Test 1 complete')
    else:
        print('Test 1 failed')
    if re.search(r"^\s*- \[X\]", test_check2):
        print('Test 2 complete')
    else:
        print('Test 2 failed')
    if re.search(r"^\s*- \[-\]", test_check3):
        print('Test 3 complete')
    else:
        print('Test 3 failed')
    if re.search(r"^\*\s", test_check4):
        print('Test 4 complete')
    else:
        print('Test 4 failed')
