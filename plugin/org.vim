vim9script
# vim: set fdm=marker:
# vim: set nospell:
g:org_sp_formula_sep = "{{{orgincommasep}}}"
g:org_sp_formula_list = [ 
  'vsum', 
  'vmean', 
  'vmax',
  'vmin', 
  'vmedian',
  'vconcat'
]

# Import section {{{
# ~/Plantillas/vim9org/autoload/spreadsheet/cells/countcells.vim
# ~/Plantillas/vim9org/autoload/spreadsheet/countformulas.vim
import autoload "base/counters/linecounters.vim" as lnc
import autoload "base/counters/stringcounters.vim" as snc
import autoload "spreadsheet/countformulas.vim" as cfr
#  }}}
def TestFormulaValidation(tb: list<list<string>>, form: string): number
  # Description: Will test all the functions.
  # Main Things: {{{
  # - Validate formula X
  # - Type of formula X
  # - Expand formula if needed X
  # - Validate Ranges X
  # - Extract Data in a range isolated X
  # - Obtain lists of cell values, and range values in a Formua to extract
  #   isolated ones, and generate lists to search and lists 
  # - Replace data in formula(s)
  # - Obtain data
  # - Don't apply in headers or empty rows/cols if there are
  # - Replace data in correct places
  # - Execute Formula
  # - Replace in list in places
  # - Put error in case
  # }}}
enddef

def TestCases() # {{{

  var list_example_1 = [
    ['33', '33   ', ' 21 ', '  11  '],
    ['  22', '3.0     ', '       ', '4.5      '],
    ['  20', ' $ 3.50 ', '  33.50', '         '],
    ['  33', '13      ', '       ', '     33.4'],
    ['30  ', '    5   ', '6      ', '         ']
  ]

  var list_example_pos = [
    [ 'R1C1', 'R1C2', 'R1C3', 'R1C4', 'R1C5', ],
    [ 'R2C1', 'R2C2', 'R2C3', 'R2C4', 'R2C5', ],
    [ 'R3C1', 'R3C2', 'R3C3', 'R3C4', 'R3C5', ],
    [ 'R4C1', 'R4C2', 'R4C3', 'R4C4', 'R4C5', ],
    [ 'R5C1', 'R5C2', 'R5C3', 'R5C4', 'R5C5', ],
  ]

  var list_example_2 = [
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
    ['   ', '   ', '    ', '      '],
  ]
  var formulas_example = [ 
    '@2$4=vmean(@2$3..@3$3,@3$4,$2,$2..$3,@3,@1..@3,,20,20)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Cell Formula
    '@4=vsum(@2$3..@3$3)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Row Formula
    '$4=vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Column Formula
    '@2$2..@3$3=vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Formula Range obtain
    '@4vsum(@2$3..@3$2)+5+vmean($2..$3)+vmin($2..$3)-vmax($2..$3)', # Wrong Formula
    '@1$3=vconcat(@1$1,@2$3)',
    "@3$2=vsum(vmean(2,4,vmin(44,22,$4,@3)),vmax(22,33,$2),vmin(12,14,$3,$5)) '( + 2 3)"
  ]

  echo formulas_example[6]
  # var stridlst1 = snc.StridxLst( formulas_example[6], '(' )
  # echo stridlst1
  # var stridlst3 = snc.StridxLst( formulas_example[6], ')' )
  # echo stridlst3
  # var stridlst2 = snc.MtchList( formulas_example[6], '\a\a(' )
  # echo stridlst2
  # var stridlst4 = snc.StridxLst( formulas_example[6], "'(" )
  # echo stridlst4
  # var stridlst5 = snc.SortTilMinPairsTxt( formulas_example[6], stridlst2 )
  var test_all_function = cfr.CalculateFormulas(formulas_example[6], list_example_1)
  # # echo DictCreate
  # var start_point = mng.ObtainStart( formulas_example[0] )
  # # echo start_point
  # var add_ranges = mng.RangeCells( DictCreate, start_point[-1], list_example_1, start_point )
  # echo add_ranges
enddef

# }}}
