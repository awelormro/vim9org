if !exists('b:org_defaults')
  let b:org_defaults =  1
endif

if b:org_defaults == 1
  finish
endif

let b:org_defaults = 1
setlocal tw=80
