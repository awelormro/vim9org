# vim: set foldmethod=indent:
# vim: set nospell:
import vim
import utils.commandextend as commnds
import linksorg as lnks
import folding
import indenting


def StartOrgpy():
    commands_to_generate = []
    buffer_commands = [
            ['n', '<silent>', '<leader>os', ':w<CR>'],
                ]
    commnds.OrgBufferMapping(buffer_commands)
    lnks.SetLinkSettings()
    indenting.SetHeadersSettings()
