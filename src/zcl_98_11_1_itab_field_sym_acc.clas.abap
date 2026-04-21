CLASS zcl_98_11_1_itab_field_sym_acc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_11_1_itab_field_sym_acc IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
* Execute this class using Profile As->abap Application
* In the analysis, look at the comparative runtimes of
* the methods loop_work_area( ) and loop_field_symbol( )


    data(flights) = new lcl_demo( ).

    flights->use_work_area( ).
    flights->use_field_symbol( ).
    out->write( 'Done' ).

  ENDMETHOD.
ENDCLASS.
