import vim
import re


"""tokens list:
    empty_line: for a whitespace
    strng, numbr, symbol, space
    """


def tokenize_org_file():
    whole_buffer = vim.current.buffer
    tokens = []
    for line in whole_buffer:
        line_tokenized = tokenize_line(line)
        tokens += line_tokenized
        print(line)
    return tokens


def tokenize_line(line: str):
    tokens = []
    i = 0
    len_line = len(line)

    if len_line == 0:
        return ['empty_line', '']
    while i < len_line:
        if re.match(r'[a-zA-Z]', line[i]):
            token = token_word(line, i, len_line)
            i = token[1]
            token_add = token[0]
            tokens.append(token_add)
            continue
        if re.match(r'\d', line[i]):
            token = token_word(line, i, len_line)
            i = token[1]
            token_add = token[0]
            tokens.append(token_add)
            continue
        if re.match(r'\s', line[i]):
            token = token_space(line, i, len_line)
            i = token[1]
            token_add = token[0]
            tokens.append(token_add)
            continue
        token_add = ['symbol', line[i]]
        tokens.append(token_add)
        i += 1
    return tokens


def token_until(expr: str, line: str, pos: int, len_line: int, type_token: str):
    i = pos
    while i < len_line:
        if i + 1 == len_line:
            return [[type_token, line[pos:i]], i]
        if re.match(expr, line[i]):
            i += 1
        else:
            return [[type_token, line[pos:i]], i]


def token_number(line: str, pos: int, len_line: int):
    i = pos
    while i < len_line:
        if re.match(r'\d', line[i]):
            i += 1
        else:
            return [['number', line[pos:i]], i]


def token_space(line: str, pos: int, len_line: int):
    i = pos
    while i < len_line:
        if re.match(r'\s', line[i]):
            i += 1
        else:
            return [['space', i - pos], i]


def token_word(line: str, pos: int, len_line: int):
    i = pos
    while i <= len_line:
        if re.match(r'[a-zA-Z]', line[i]):
            i += 1
        else:
            return [['word', line[pos:i]], i]
