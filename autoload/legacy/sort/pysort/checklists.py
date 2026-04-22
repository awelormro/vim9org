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
    import vim
    import re

    prev_blankline = vim.Function('search')('^\\s$', 'nWb')
    next_blankline = vim.Function('search')('^\\s$', 'nW')

    # Check the position of the previous and next headers
    prev_header = vim.Function('search')('^\\*', 'nWb')
    next_header = vim.Function('search')('^\\*', 'nW')

    # Check if blankline or header is previous

    if prev_header > prev_blankline:
        start_search = prev_header - 1
    elif prev_header < prev_blankline:
        start_search = prev_blankline - 1
    else:
        start_search = 1

    # Check if blankline or header is next

    if next_header < next_blankline:
        end_search = next_header
    elif next_header > next_blankline:
        end_search = next_blankline
    else:
        end_search = vim.Function('line')('$')

    range_lines = vim.current.buffer[start_search:end_search]
    print(range_lines)

    # Generate a list with the line number and content of every checkbox

    i = start_search
    checklist_list = []
    end_total = vim.Function('line')('$')
    while i < end_total:
        if re.search(r"^\s*- \["):
            indent = vim.current.buffer[i] - vim.current.buffer[i].lstrip()
            list_add = [i, indent, vim.current.buffer[i]]
            checklist_list.append(list_add)
            i += 1
            continue
        elif i == end_search:
            break
        else:
            i += 1
            continue

    print(checklist_list)

    # Count main and childs
    # Loop to substitute the positions


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
