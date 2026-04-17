CLASS zcl_98_05_1_sql_join_syntax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_05_1_sql_join_syntax IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    SELECT FROM /dmo/carrier INNER JOIN /dmo/connection
    SELECT FROM /dmo/carrier AS ca INNER JOIN /dmo/connection AS co
             ON ca~carrier_id = co~carrier_id

         FIELDS ca~carrier_id,
                ca~name AS carrier_name,
                connection_id,
                airport_from_id,
                airport_to_id,
                departure_time,
                arrival_time

          WHERE ca~currency_code = 'EUR'
           INTO TABLE @DATA(result).

    out->write(
      EXPORTING
        data   = result
        name   = 'RESULT'
    ).

  ENDMETHOD.
ENDCLASS.
