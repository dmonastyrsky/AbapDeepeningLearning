CLASS zcl_98_tesl_st_connect DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_98_tesl_st_connect IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TYPES:
      BEGIN OF st_connections_buffer,
        carrier_id      TYPE /dmo/carrier_id,
        connection_id   TYPE /dmo/connection_id,
        airport_from_id TYPE /dmo/airport_from_id,
        airport_to_id   TYPE /dmo/airport_to_id,
        from_time_zone  TYPE timezone,
        to_time_zone    TYPE timezone,
        departure_time  TYPE /dmo/flight_departure_time,
        arrival_time    TYPE /dmo/flight_departure_time,
        duration        TYPE i,
      END OF st_connections_buffer.

    DATA connections_buffer TYPE TABLE OF st_connections_buffer.

    SELECT FROM z98_airport
      FIELDS airport_id, time_zone
     " TODO: variable is assigned but never used (ABAP cleaner)
      INTO TABLE @DATA(airports).

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    " Preload connection data into buffer
    SELECT
      FROM /dmo/connection AS conn                      "#EC CI_NOWHERE
             LEFT OUTER JOIN
               z98_airport AS from_apt ON conn~airport_from_id = from_apt~airport_id
                 LEFT OUTER JOIN
                   z98_airport AS to_apt ON conn~airport_to_id = to_apt~airport_id
      FIELDS conn~carrier_id,
             conn~connection_id,
             conn~airport_from_id,
             conn~airport_to_id,
             conn~departure_time,
             conn~arrival_time,
             from_apt~time_zone                                                                                 AS from_time_zone,
             to_apt~time_zone                                                                                   AS to_time_zone,
             CASE
              WHEN dats_tims_to_tstmp( date  = @today,
                                       time  = conn~arrival_time,
                                       tzone = to_apt~time_zone )
                   < dats_tims_to_tstmp( date  = @today,
                                         time  = conn~departure_time,
                                         tzone = from_apt~time_zone )
              THEN div( tstmp_seconds_between( tstmp1 = dats_tims_to_tstmp( date  = @today,
                                                                            time  = conn~departure_time,
                                                                            tzone = from_apt~time_zone ),
                                               tstmp2 = dats_tims_to_tstmp( date  = dats_add_days( @today, 1 ),
                                                                            time  = conn~arrival_time,
                                                                            tzone = to_apt~time_zone ) )
                        , 60 )
              ELSE div( tstmp_seconds_between( tstmp1 = dats_tims_to_tstmp( date  = @today,
                                                                            time  = conn~departure_time,
                                                                            tzone = from_apt~time_zone ),
                                               tstmp2 = dats_tims_to_tstmp( date  = @today,
                                                                            time  = conn~arrival_time,
                                                                            tzone = to_apt~time_zone ) )
                        , 60 )
             END                    AS duration
      INTO CORRESPONDING FIELDS OF TABLE @connections_buffer.

*    LOOP AT connections_buffer INTO DATA(connection).
*        CONVERT DATE today
*              TIME connection-departure_time
*              TIME ZONE connection-from_time_zone
*              INTO UTCLONG DATA(departure_utclong).
*
*        CONVERT DATE today
*              TIME connection-arrival_time
*              TIME ZONE connection-to_time_zone
*              INTO UTCLONG DATA(arrival_utclong).
*
*         " Handle flights that cross midnight (arrival next day)
*         IF arrival_utclong < departure_utclong.
*           arrival_utclong = utclong_add( val = arrival_utclong seconds = 86400 ). " Add 24 hours
*         ENDIF.
*
*         connection-duration = utclong_diff( high = arrival_utclong
*                                          low  = departure_utclong
*                                        ) / 60.
*
*         MODIFY connections_buffer FROM connection TRANSPORTING duration.
*
*    ENDLOOP.

    out->write( '--- FINAL BUFFER CONTENT ---' ).
    out->write( connections_buffer ).
  ENDMETHOD.
ENDCLASS.
