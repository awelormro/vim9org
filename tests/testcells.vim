vim9script

export def TestEvalFormula()
  var frmla_string_dta = [2, 4, "vsum(vmax($2,$3),vmin(@2,@3))+'( + $1 $3 )"]
  var i = 0
  var data_example_1 = [ 
    [' Texto',     'Área', 'Ronda', 'Estado'],
    ['Encabezado', '22',   '11',    '33'    ],
    ['Parte',      '11',   '1',     '33'    ],
    ['Efecto',     '23',   '12',    '22'    ],
  ]
enddef
