CLASS zcl_98_09_4_sql_group_by DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_09_4_sql_group_by IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

SELECT FROM /dmo/connection

     FIELDS
            carrier_id,
            MAX( distance ) AS max,
            MIN( distance ) AS min,
            SUM( distance ) AS sum,
            COUNT( * ) AS count

     GROUP BY carrier_id
     INTO TABLE @DATA(result).

    out->write(
      EXPORTING
        data   = result
        name   = 'RESULT'
    ).

  ENDMETHOD.
ENDCLASS.
