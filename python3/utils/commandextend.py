# vim: set foldmethod=indent:
import vim
import os


def Orgmapping( mapslist ):
    """ Indications:
        mapslist syntax: [ type, additional args, mapping, command ]
        additional args like <buffer>, <expr>, <silent>
    """
    for mapping in mapslist:
        if mapping[0] == 'n':
            kindmap = "nnoremap"
        elif mapping == 'i':
            kindmap = "inoremap"
        elif mapping == 'v':
            kindmap = 'vnoremap'
        elif mapping == 't':
            kindmap = 'tnoremap'
        else:
            kindmap = 'nnoremap'
        maptoadd = kindmap + " " + mapping[1] + " " + mapping[2] + " " + mapping[3]
        # print(maptoadd)
        vim.command( maptoadd )


def OrgMapping( mapslist ):
    """ Indications:
        mapslist syntax: [ type, additional args, mapping, command ]
        additional args like <buffer>, <expr>, <silent>
    """
    for mapping in mapslist:
        if mapping[0] == 'n':
            kindmap = "nnoremap"
        elif mapping == 'i':
            kindmap = "inoremap"
        elif mapping == 'v':
            kindmap = 'vnoremap'
        elif mapping == 't':
            kindmap = 'tnoremap'
        else:
            kindmap = 'nnoremap'
        maptoadd = kindmap + " " + mapping[1] + " " + mapping[2] + " " + mapping[3]
        # print(maptoadd)
        vim.command( maptoadd )


def OrgBufferMapping( mapslist ):
    """ Indications:
        mapslist syntax: [ type, additional args, mapping, command ]
        additional args like <buffer>, <expr>, <silent>
    """
    for mapping in mapslist:
        if mapping[0] == 'n':
            kindmap = "nnoremap"
        elif mapping == 'i':
            kindmap = "inoremap"
        elif mapping == 'v':
            kindmap = 'vnoremap'
        elif mapping == 't':
            kindmap = 'tnoremap'
        else:
            kindmap = 'nnoremap'
        maptoadd = kindmap + " <buffer> " + mapping[1] + " " + mapping[2] + " " + mapping[3]
        # print(maptoadd)
        vim.command( maptoadd )


def OrgEvaluation():
    pass


def OrgCommandBuffer( command_list ):
    """ Indications:
        The command_list list must be [ command_name, libtoimport, command_indicators ], 
        in this way always will be declared previously on python 3
    """
    for command in command_list:
        # print(type(command_list[1]))
        if isinstance(command[1], str) and (command[1].isspace() or not command[1]):
            generate_command = 'command! -buffer ' + command[0] + " :py3 " + command[2]
        else:
            generate_command = 'command! -buffer ' + str(command[0]) + \
                               " :py3 import " + str(command[1]) + "; " + str(command[1]) + \
                               "." + str(command[2])
        # print(generate_command)
        vim.command(generate_command)


def OrgCommand(commandlist):
    """ Indications:
        The command_list list must be [ command_name, libtoimport, command_indicators, extras1, extras2 ], 
        in this way always will be declared previously on python 3
    """
    for command in command_list:
        # print(type(command_list[1]))
        if isinstance(command[1], str) and (command[1].isspace() or not command[1]):
            generate_command = 'command! ' + command[0] + " :py3 " + command[2]
        else:
            generate_command = 'command! -buffer ' + str(command[0]) + \
                               " :py3 import " + str(command[1]) + "; " + str(command[1]) + \
                               "." + str(command[2])
        # print(generate_command)
        vim.command(generate_command)
