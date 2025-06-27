if !has('vim9script')
  finish
endif
vim9script

import autoload "v9sc/checkbox.vim" as chck
import autoload "v9sc/nrrow.vim" as narrow
import autoload "v9sc/nrrowbuf.vim" as nrrowbuf
import autoload "v9sc/parser.vim" as parser
import autoload "v9sc/searchbuffers.vim" as search
import autoload "v9sc/searchers.vim" as searchers
import autoload "v9sc/tags.vim" as tgs
import autoload "v9sc/tokenizers.vim" as tokenizer


export def General_start()
  echo 'Vim9script core loaded'
enddef
