# vim: set foldmethod=indent:
import vim
import os
import re
import utils.commandextend as comext

def GoBackwardHeader():
    vim.command("call search('^*', 'b')")


def GoFowardHeader():
    vim.command("call search('^*')")


def GoFowardLink():
    vim.command( "call search('[[','')" )


def GoBackwardLink():
    vim.command( "call search('[[','b')" )


def EnterLink():
    cont_cursor = vim.current.line
    link_borders = LinkStartAndEnd()
    link_content = cont_cursor[link_borders[0]:link_borders[1]][2:-2]
    partslink = SplitLink(link_content)
    LinkActions(partslink[0])


def LinkActions(orglink):
    if re.match('^~', orglink):
        print('Local file')
        preamble = vim.eval('expand("%:h")')
        full_filename = preamble + orglink[1:]
        vim.command('e ' + full_filename)
    elif re.match('^/home', orglink):
        print('Local file')
        vim.command('e ' + orglink)
    elif re.match('^/', orglink):
        print('subsequent file in this path')
        preamble = vim.eval('expand("%:h")')
        full_filename = preamble + orglink
        vim.command('e '+ full_filename)
    elif re.match('^vim:', orglink):
        print('Vimscript command')
        vim.command(orglink[3:])
    elif re.match('^lua:', orglink):
        print('Lua command')
        vim.command('lua ' + orglink[4:])
    elif re.match('^bash:', orglink):
        print('Shell command')
        vim.command('!' + orglink[5:])
    elif re.match('^python:', orglink):
        print('Python command')
        vim.command('py3 ' + orglink[7:])


def SplitLink(orglink):
    if '][' in orglink:
        return orglink.split('][')
    else:
        return [ orglink ]


def LinkStartAndEnd():
    pos = vim.current.window.cursor
    print(pos[1])
    # Obtener la posición actual del cursor
    pos_cursor = vim.current.window.cursor  # (línea, columna)
    cont_cursor = vim.current.line  # Contenido de la línea actual
    i = pos_cursor[1]
    beg_link = None
    end_link = None
    while i > 1:
        if cont_cursor[i-2:i] == '[[':
            # print('estás dentro del inicio de un link ')
            beg_link = i - 2
            break
        elif cont_cursor[i] == '[' and cont_cursor[i+1] == '[':
            # print('estás dentro del inicio de un link ')
            beg_link = i
            break
        else:
            i -= 1
    if beg_link is not None:
        i = pos_cursor[1]
        while i < len(cont_cursor) - 1:
            if cont_cursor[i:i+2] == ']]':
                # print('Tu link tiene cierre')
                end_link = i + 2
                break
            elif cont_cursor[i] == ']' and cont_cursor[i-1] == ']':
                end_link = i + 2
                break
            else:
                i += 1
    return [ beg_link, end_link ]


def CommandsLinks():
    command_list = [ 
                    ['OrgLinkForward',    'linksorg', 'GoFowardLink()'], 
                    ['OrgLinkBackward',   'linksorg', 'GoBackwardLink()'], 
                    ['OrgHeaderForward',  'linksorg', 'GoFowardHeader()'], 
                    ['OrgHeaderBackward', 'linksorg', 'GoBackwardHeader()'], 
                    ['OrgLinkEnter',      'linksorg', 'EnterLink()' ],
                    ]
    comext.OrgCommandBuffer( command_list )


def MappingsLinks():
    mapping_list = [
            ['n', '<silent>', '<leader>oln', ':OrgLinkForward<CR>'],
            ['n', '<silent>', '<leader>olp', ':OrgLinkBackward<CR>'],
            ['n', '<silent>', '<leader>ohn', ':OrgHeaderForward<CR>'],
            ['n', '<silent>', '<leader>ohp', ':OrgHeaderBackward<CR>'],
            ['n', '<silent>', '<leader>ole', ':OrgLinkEnter<CR>'],
            ]
    comext.OrgBufferMapping(mapping_list)


def SetLinkSettings():
    CommandsLinks()
    MappingsLinks()
