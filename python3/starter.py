# vim: set foldmethod=indent:
# vim: set nospell:
import vim
import utils.commandextend as commnds
import linksorg as lnks
import folding

def StartOrgpy():
    commands_to_generate = []
    # runtime 
    buffer_commands = [
            ['n', '<silent>', '<leader>os', ':w<CR>'],
                ]
    commnds.OrgBufferMapping(buffer_commands)
    lnks.SetLinkSettings()

