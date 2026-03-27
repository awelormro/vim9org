"""
timestamps.py - VERSIÓN CORREGIDA Y COMPLETA
"""

import vim
import utils as ut
import re


def search_timestamp(pos: int, ln: str):
    # Verify if exists date vim global files
    # Check if cursor is inside an active or inactive timestamp
    verifier = ut.is_inside_of(ln, pos, '<', '>')
    verifier_kind = 'a'
    if verifier[0] == -1:
        verifier = ut.is_inside_of(ln, pos, '[', ']')
        verifier_kind = 'i'
    if verifier[0] == -1:
        return

    # Start processing the date
    stamp_process = ln[verifier[0]:verifier[1] + 1]
    date_splitted = split_string_date(stamp_process, verifier_kind)
    if len(date_splitted) == 0:
        return
    print(date_splitted)


def split_string_date(date: str, kind: str):
    if kind == 'a':
        if not re.search(r'<\d{4}-\d{2}-\d{2} .+?>', date):
            print('not the form')
            return []
    if kind == 'i':
        if not re.search(r'\[\d{4}-\d{2}-\d{2} .+?\]', date):
            print('not the form')
            return []
    split_list = date[1:-1].split()
    date_split = split_list[0].split('-')
    return date_split + split_list[1:]


def test_inside():
    print('Test 1')
    str_test1 = '** Perros en la pradera <2024-10-11 Tue 12:30>'
    print('Test 2')
    str_test2 = '** Perros en la pradera [2025-10-11 Tue 12:30]'
    print('Test 3')
    str_test3 = '<2022-10-11 Tue 12:30>'
    search_timestamp(25, str_test1)
    search_timestamp(25, str_test2)
    search_timestamp(0, str_test3)


test_inside()
