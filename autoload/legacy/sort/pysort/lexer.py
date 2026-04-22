def parse_line():
    import vim
    import re
    cont = vim.current.line
    i = 0
    tokens = []
    len_ln = len(cont)
    while i < len_ln:
        i += 1
        if re.search(r"\a", cont[i]):
            ret = parse_word(cont, i)
            i = ret[0]
            tokens.append(ret[1])
            continue
        elif re.search(r"\n", cont[i]):
            ret = parse_number(cont, i)
            i = ret[0]
            tokens.append(ret[1])
            continue
        elif re.search(r"\s", cont[i]) or re.search(r"\t", cont[i]):
            ret = parse_space(cont, i)
            i = ret[0]
            tokens.append(ret[1])
            continue
        else:
            ret = parse_symbol(cont, i)
            i = ret[0]
            tokens.append(ret[1])


def parse_space(line, i):
    import re
    pos = i
    len_line = len(line)
    space_token = 0
    while pos < len_line:
        if re.search(r"\s", line[pos]) or re.search(r"\t", line[pos]):
            space_token += 1
            pos += 1
        else:
            return [pos, ['space', space_token]]


def parse_word(line, i):
    import re
    pos = i
    len_line = len(line)
    word_token = line[i]
    while pos < len_line:
        if re.search(r"\a", line[pos]):
            word_token += line[pos]
            pos += 1
        else:
            return [pos, ['word', word_token]]


def parse_number(line, i):
    import re
    pos = i
    len_line = len(line)
    number_token = line[i]
    while pos < len_line:
        if re.search(r"\d", line[pos]):
            number_token += line[pos]
            pos += 1
        else:
            return [pos, ['number', number_token]]


def parse_symbol(line, i):
    pos = i + 1
    return [pos, ['symbol', line[i]]]


def parse_range(ran):
    for line in ran:
        line_parsed = parse_line(line)
        print(line_parsed)
