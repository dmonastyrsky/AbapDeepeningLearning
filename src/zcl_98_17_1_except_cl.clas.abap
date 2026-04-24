CLASS zcl_98_17_1_except_cl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_98_17_1_except_cl IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA number1 TYPE i                     VALUE 2000000000.
    DATA number2 TYPE p LENGTH 2 DECIMALS 1 VALUE '0.5'.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA result  TYPE i.

    TRY.

        result = number1 / number2.

      CATCH cx_sy_arithmetic_overflow.
        out->write( 'Arithmetic Overflow' ).
      CATCH cx_sy_zerodivide.
        out->write( 'Division by zero' ).
    ENDTRY.

    number2 = 0.
    TRY.

        result = number1 / number2.

      CATCH cx_sy_arithmetic_overflow.
        out->write( 'Arithmetic Overflow' ).
      CATCH cx_sy_zerodivide.
        out->write( 'Division by zero' ).
    ENDTRY.

    TRY.
        result = number1 / number2.

      CATCH cx_sy_arithmetic_overflow
            cx_sy_zerodivide.
        out->write( 'Arithmetic overflow or division by zero' ).
    ENDTRY.

    TRY.
        result = number1 / number2.
      CATCH cx_sy_arithmetic_error InTO DATA(exp) .
        out->write( 'Caught both exceptions using their common superclass' ).
        out->write( exp->get_text( ) ).

    ENDTRY.

    TRY.
        result = number1 / number2.
      CATCH cx_root.
        out->write( 'Caught any exception using CX_ROOT' ).
    ENDTRY.

    TRY.
        result = number1 / number2.
      CATCH cx_root INTO DATA(Exception).
        out->write( 'Used INTO to intercept the exception object' ).
        out->write( 'The get_Text( ) method returns the following error text: ' ).
        out->write( Exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
