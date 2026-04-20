CLASS zcl_98_09_3_sql_aggregate_func DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_09_3_sql_aggregate_func IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT FROM /dmo/connection
         FIELDS carrier_id,
                connection_id,
                airport_from_id,
                distance
          WHERE carrier_id = 'LH'
           INTO TABLE @DATA(result_raw).


    out->write(
      EXPORTING
        data   = result_raw
        name   = 'RESULT_RAW'
    ).

*********************************************************************

    SELECT FROM /dmo/connection
         FIELDS MAX( distance ) AS max,
                MIN( distance ) AS min,
                SUM( distance ) AS sum,
                AVG( distance ) AS average,
                COUNT( * ) AS count,
                COUNT( DISTINCT airport_from_id ) AS count_dist

          WHERE carrier_id = 'LH'
           INTO TABLE @DATA(result_aggregate).

    out->write(
      EXPORTING
        data   = result_aggregate
        name   = 'RESULT_AGGREGATED'
    ).

  ENDMETHOD.
ENDCLASS.
