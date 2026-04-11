CLASS zcl_98_02_type_conversions_2 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_98_02_type_conversions_2 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA long_char  TYPE c LENGTH 10.
    DATA short_char TYPE c LENGTH 5.

    DATA result     TYPE p LENGTH 3  DECIMALS 2.

    DATA var_pack   TYPE p LENGTH 3  DECIMALS 2.

    DATA temp TYPE f.

    long_char = 'ABCDEFGHIJ'.
    short_char = long_char.

    out->write( |long_char: { long_char }|  ).
    out->write( |short_char: { short_char }|  ).

    result = 1 / 8.
    out->write( |1 / 8 is rounded to { result NUMBER = USER }| ).

    var_pack = 1 / 4.

    out->write( var_pack ).

    var_pack = 1 / 9.

    out->write( |1 / 9 = { CONV f( 1 ) / CONV f( 9 ) DECIMALS = 5 }| ).
    out->write( var_pack ).

    DATA(rounded) = 5 / 10.
    out->write( |5 / 10 rounded : { rounded  }| ).

    TRY.
        out->write( |1 / 9 = : { EXACT #( 1 / 9 ) }| ).
      CATCH cx_sy_conversion_rounding.
        out->write( 'EXACT #( 1 / 9 ) rounding error' ).
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
