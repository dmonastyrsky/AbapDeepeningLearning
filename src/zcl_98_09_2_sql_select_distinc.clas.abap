CLASS zcl_98_09_2_sql_select_distinc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_09_2_sql_select_distinc IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    SELECT FROM /dmo/connection
       FIELDS
           DISTINCT
              airport_from_id,
              distance_unit

     ORDER BY airport_from_id
         INTO TABLE @DATA(result).

    out->write(
      EXPORTING
        data   = result
        name   = 'RESULT'
    ).

  ENDMETHOD.

ENDCLASS.
