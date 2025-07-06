import os


def read_entire_file(path):
    expanded_path = os.path.expanduser(path)
    with open(expanded_path, 'r') as f:
        return f.read().splitlines()


pendejada = read_entire_file('~/cosa.org')
print(pendejada)
