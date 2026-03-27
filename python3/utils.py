import vim
import re


def vfunction_utf8(func: str, stuff):
    return vim.Function(func)(stuff).decode('utf-8')


def is_inside_of(thing: str, pos: int, left_border: str, right_border: str):
    is_left = thing.rfind(left_border, 0, pos + 1)

    if is_left < 0:
        return [-1, -1]

    print('left border passed')

    is_right = thing.find(right_border, pos)

    if is_right < 0:
        return [-1, -1]

    print('right border passed')
    return [is_left, is_right]


def test_vf_utf8():
    test_1 = vfunction_utf8('getline', '.')
    test_2 = vfunction_utf8('getline', '$')
    print(type(test_1))
    print(test_2)


def test_inside():
    str_test1 = '** Perros en la pradera <2022-10-11 Tue 12:30>'
    str_test2 = '** Perros en la pradera [2022-10-11 Tue 12:30]'
    str_test3 = '<2022-10-11 Tue 12:30>'
    print(is_inside_of(str_test1, 30, '<', '>'))
    print(is_inside_of(str_test1, 31, '[', ']'))
    print(is_inside_of(str_test2, 32, '<', '>'))
    print(is_inside_of(str_test2, 33, '[', ']'))
    print(is_inside_of(str_test3, 20, '<', '>'))


# Passed
# test_vf_utf8()
# Status: Passed
# test_inside()
