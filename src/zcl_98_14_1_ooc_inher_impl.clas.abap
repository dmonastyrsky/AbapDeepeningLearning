CLASS zcl_98_14_1_ooc_inher_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_14_1_ooc_inher_impl IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " 1. Instance of the base plane class
    DATA(lo_plane) = NEW lcl_plane( iv_manufacturer = 'Boeing'
                                     iv_type         = '747' ).
    DATA(lt_attributes_base) = lo_plane->get_attributes( ).

    out->write( '--- Base Plane Attributes ---' ).
    out->write( lt_attributes_base ).

    " 2. Instance of the cargo plane subclass
    DATA(lo_cargo) = NEW lcl_cargo_plane( iv_manufacturer = 'Antonov'
                                           iv_type         = 'An-124'
                                           iv_cargo        = 150000 ).
    DATA(lt_attributes_cargo) = lo_cargo->get_attributes( ).

    out->write( '--- Cargo Plane Attributes ---' ).
    out->write( lt_attributes_cargo ).

    " 3. Instance of the passenger plane subclass
    DATA(lo_passenger) = NEW lcl_passenger_plane( iv_manufacturer = 'Airbus'
                                                 iv_type         = 'A380'
                                                 iv_seats        = 500 ).
    DATA(lt_attributes_pass) = lo_passenger->get_attributes( ).

    out->write( '--- Passenger Plane Attributes ---' ).
    out->write( lt_attributes_pass ).

  ENDMETHOD.

ENDCLASS.
