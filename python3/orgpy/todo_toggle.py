def toggle_todo11(fwd: bool) -> None:
    import vim
    header_pos = vim.Function('search')('^\\*', 'nWb')
    if header_pos == -1:
        return

    header = vim.current.buffer[header_pos - 1]
    head_splitted = header.split()
    if len(head_splitted) < 2:
        return

    generate_variables_todo()
    flag = verify_if_in_list_bytes()
    print(flag)


def generate_variables_todo():
    import vim
    if 'org_todo_kw' not in vim.vars:
        vim.vars['org_todo_kw'] = [
                'TODO', 'DOING', 'DONE'
                ]


def verify_if_in_list_bytes(ls, itm):
    item_conversion = bytes(itm, 'utf-8')
    if item_conversion in ls:
        return ls.index(item_conversion)
    return -1


def verify_pos_second_word(header: list) -> None:
    import vim
    header_list = vim.vars['org_todo_kw']
    variables = [0, 0, 0, 0]  # Forward, is_todo first_pos, last_pos
    if header in header_list:
        variables[1] = 1
    # if 


def toggle_todo(fwd: bool) -> None:
    import vim
    header_pos = vim.Function('search')('^\\*', 'nWb')

    if header_pos == -1:
        return

    header = vim.current.buffer[header_pos - 1]
    head_splitted = header.split()

    if len(head_splitted) < 2:
        return

    if 'org_todo_keywords' not in vim.vars:
        vim.vars['org_todo_keywords'] = [
                'TODO', 'DOING', 'DONE'
                ]
    move = 1 if fwd else -1
    curr_state = bytes(head_splitted[1], 'utf-8')
    todo_keywords = list(vim.vars['org_todo_keywords'])
    flag_fix = False
    if curr_state not in todo_keywords:
        # DONE
        if fwd:
            head_splitted.insert(1, str(todo_keywords[0]))
        # DONE
        else:
            head_splitted.insert(1, str(todo_keywords[-1]))
    else:
        pos_todo = todo_keywords.index(curr_state)
        if fwd and (pos_todo >= (len(todo_keywords) - 1)):
            head_splitted.pop(1)
            flag_fix = True
        elif not fwd and pos_todo == 0:
            head_splitted.pop(1)
            flag_fix = True
        else:
            head_splitted.pop(1)
            head_splitted.insert(1, str(todo_keywords[pos_todo + move]))
    new_head = head_splitted[0]
    head_splitted[1] = head_splitted[1] if flag_fix else head_splitted[1][2:-1]
    new_head_experiment = ' '.join(head_splitted)
    i = 1
    len_head = len(new_head)
    while i < len_head:
        new_head = new_head + ' ' + head_splitted[i]
        i += 1
    vim.current.buffer[header_pos - 1] = new_head_experiment


