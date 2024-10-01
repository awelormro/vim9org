vim9script
# /home/abu/Plantillas/vim9org/autoload/spreadsheet/countformulas.vim
import autoload "spreadsheet/countformulas.vim" as cfo
export def AssertEqual(actual: string, expected: string, testf: string)
  if actual ==# expected
    echo testf .. ' Passed'
  else
    echoerr testf .. ' Failed: expected' .. expected .. ' but obtained ' .. actual
  endif
enddef

export def TestSpread()
  var test_dta = [ 
    [ '$ 2',  '4.0',  '5.0'  ],
    [ '2',    '4  ',  'cell' ],
    [ '33',   '12',   'txt'  ]
  ]
  var cell_frmls = [ '@4=sum($1..$3)', '@1$3=3+5' ]
  AssertEqual( string( 2 + 2 ), '4', 'sumlocal' )
  AssertEqual( cfo.Datainfo(cell_frmls[1]), '1', 'Datainfo' )
enddef
