CLASS zcl_98_02_type_conversions DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_02_type_conversions IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA var_string TYPE string.
    DATA var_int TYPE i.
    DATA var_date TYPE d.
    DATA var_pack TYPE p LENGTH 3 DECIMALS 2.


    var_string = `12345`.
    var_int = var_string.

    out->write( |String value: { var_string }| ).
    out->write( |Date int: { var_int }| ).


    out->write( 'Conversion successful' ).


    var_string = `20230101`.
    var_date = var_string.


    out->write( |String value: { var_string }| ).
    out->write( |Date Value: { var_date DATE = USER }| ).
  ENDMETHOD.
ENDCLASS.
