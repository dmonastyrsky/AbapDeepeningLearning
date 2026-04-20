CLASS zcl_98_09_1_sql_order_by DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_09_1_sql_order_by IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT FROM /dmo/flight
         FIELDS carrier_id,
                connection_id,
                flight_date,
                seats_max - seats_occupied AS seats
*          WHERE carrier_id     = 'AA'
*            AND plane_type_id  = 'A320-200'
       ORDER BY seats_max - seats_occupied DESCENDING,
                flight_date                ASCENDING
           INTO TABLE @DATA(result).

    out->write(
      EXPORTING
        data   = result
        name   = 'RESULT'
    ).

  ENDMETHOD.
ENDCLASS.
