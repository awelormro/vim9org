if !has('python3')
  finish
endif

if exists('b:org_started')
  finish
endif

echo 'has python3 started'
let b:org_started = 1
py3 import orgpy.starter as start
py3 start.org_globals_start()
