import vim
# Remember matchbufline, for ast generation


def nrback(fn: str, args: str) -> any:
    generated = vim.eval(f'{fn}({args})')
    try:
        return int(generated)
    except TypeError:
        return generated


def search_py(what: str, extras: str) -> int:
    return int(vim.eval(f'call search("{what}", "{extras}")'))


def is_inside_of(lborder: str, rborder: str) -> list[any]:
    """
    Verifica si la posición actual está dentro de lborder...rborder
    Incluye los delimitadores en el rango.

    Returns:
        [start, end] si está dentro, [-1, -1] si no
    """
    curr_pos = vim.current.window.cursor[1]
    curr_line = vim.current.line

    # Caso borde: posición fuera de la línea
    if curr_pos < 0 or curr_pos >= len(curr_line):
        return [-1, -1]

    # Buscar lborder (puede estar en la posición actual o antes)
    lborder_pos = curr_line.rfind(lborder, 0, curr_pos + 1)
    if lborder_pos == -1:
        return [-1, -1]

    # Buscar rborder después de lborder
    search_start = lborder_pos + len(lborder)
    rborder_pos = curr_line.find(rborder, search_start)
    if rborder_pos == -1:
        return [-1, -1]

    # Calcular rango completo incluyendo delimitadores
    start = lborder_pos  # primer caracter de lborder
    end = rborder_pos + len(rborder) - 1  # último caracter de rborder

    # Verificar si posición actual está en el rango
    if start <= curr_pos <= end:
        return [start, end]

    return [-1, -1]


def insert_in_position(adding: str) -> None:
    vl = vim.current.line
    curr_pos = vim.current.window.cursor
    if curr_pos[1] == 0:
        p1 = adding
        p2 = vl
        vim.current.buffer[curr_pos[1] - 1] = p1 + p2
        return
    if curr_pos[1] == len(vl) - 1:
        p1 = vl
        p2 = adding
        vim.current.buffer[curr_pos[1] - 1] = p1 + p2
        return
    else:
        p1 = vim.current.buffer[: curr_pos[1] - 1]
        p2 = adding
        p3 = vim.current.buffer[: curr_pos[1] - 1]
        vim.current.buffer[curr_pos[1] - 1] = p1 + p2 + p3


def vinput(input_frame: str) -> str:
    return vim.eval(f'input("{input_frame}")')
