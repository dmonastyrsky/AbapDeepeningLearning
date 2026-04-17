CLASS zcl_98_06_1_sql_exp_literals DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_98_06_1_sql_exp_literals IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    CONSTANTS c_number TYPE i VALUE 1234.

    SELECT FROM /dmo/carrier
      FIELDS 'Hello'    AS Character,    " Type c
             1          AS Integer1,     " Type i
             -1         AS Integer2,     " Type i
             CAST( '20240601' AS DATS ) AS Date,         " Type d
             '235959'   AS Time,         " Type t
             'X'        AS Boolean,      " Type abap_bool
             1234       AS Number,       " Type i (same as c_number)
             @c_number  AS constant      " Type i  (same as constant)

      INTO TABLE @DATA(result).

    out->write( data = result
                name = 'RESULT' ).
  ENDMETHOD.
ENDCLASS.
