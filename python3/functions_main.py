import vim

cb = vim.current.buffer
cw = vim.current.window
cl = vim.current.line
w = vim.windows
b = vim.buffers
g = vim.vars
v = vim.vvars
fn = vim.Function
bb = vim.current.buffer.vars
cursor_current = vim.current.window.cursor
exists = vim.Function('exists')
cursor = vim.Function('cursor')
expand = vim.Function('expand')
getline = vim.Function('getline')
indent = vim.Function('indent')
line = vim.Function('line')
matchfuzzy = vim.Function('matchfuzzy')
mode = vim.Function('mode')
nextnonblank = vim.Function('nextnonblank')
prevnonblank = vim.Function('prevnonblank')
resolve = vim.Function('resolve')
search = vim.Function('search')
setline = vim.Function('setline')
substitute = vim.Function('substitute')
