*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*  CLASS lcl_flight DEFINITION CREATE PRIVATE.
  CLASS lcl_flight DEFINITION ABSTRACT.

    PUBLIC SECTION.

      TYPES: tab TYPE STANDARD TABLE OF REF TO lcl_flight WITH DEFAULT KEY.

      TYPES: BEGIN OF st_connection_details,
               airport_from_id TYPE /dmo/airport_from_id,
               airport_to_id   TYPE /dmo/airport_to_id,
               departure_time  TYPE /dmo/flight_departure_time,
               arrival_time    TYPE /dmo/flight_departure_time,
               duration        TYPE i,
             END OF st_connection_details.

      DATA carrier_id    TYPE /dmo/carrier_id       READ-ONLY.
      DATA connection_id TYPE /dmo/connection_id    READ-ONLY.
      DATA flight_date   TYPE /dmo/flight_date      READ-ONLY.

      METHODS constructor
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
          i_connection_id TYPE /dmo/connection_id
          i_flight_date   TYPE /dmo/flight_date.

      METHODS: get_connection_details
        RETURNING
          VALUE(r_result) TYPE st_connection_details.

      METHODS get_description
        RETURNING
          VALUE(r_result) TYPE string_table.

    PROTECTED SECTION.
      DATA planetype  TYPE /dmo/plane_type_id.
      DATA connection_details TYPE st_connection_details.
    PRIVATE SECTION.
  ENDCLASS.

  CLASS lcl_flight IMPLEMENTATION.

    METHOD get_connection_details.
      r_result = me->connection_details.
    ENDMETHOD.

    METHOD get_description.

*    APPEND |Flight { carrier_id } { connection_id } on { flight_date DATE = USER } | &&
*           |from { connection_details-airport_from_id } to { connection_details-airport_to_id } |
*           TO r_result.

      DATA txt TYPE string.

      txt = 'Flight &carrid& &connid& on &date& from &from& to &to&'(005).
      txt = replace( val = txt sub = '&carrid&' with = carrier_id ).
      txt = replace( val = txt sub = '&connid&' with = connection_id ).
      txt = replace( val = txt sub = '&date&'   with = |{ flight_date DATE = USER }| ).
      txt = replace( val = txt sub = '&from&'   with = connection_details-airport_from_id ).
      txt = replace( val = txt sub = '&to&'     with = connection_details-airport_to_id ).
      APPEND txt TO r_result.

      APPEND |{ 'Planetype:'(006)      } { planetype  } | TO r_result.

    ENDMETHOD.

    METHOD constructor.
      me->carrier_id    = i_carrier_id.
      me->connection_id = i_connection_id.
      me->flight_date   = i_flight_date.
    ENDMETHOD.

ENDCLASS.

  CLASS lcl_passenger_flight DEFINITION
    INHERITING FROM lcl_flight.

    PUBLIC SECTION.

      METHODS constructor
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
          i_connection_id TYPE /dmo/connection_id
          i_flight_date   TYPE /dmo/flight_date.

      TYPES
        tt_flights TYPE STANDARD TABLE OF REF TO lcl_passenger_flight WITH DEFAULT KEY.

      METHODS
        get_free_seats
          RETURNING
            VALUE(r_result) TYPE i.

*  methods get_description
*    RETURNING
*      VALUE(r_result) TYPE string_table.
      METHODS get_description REDEFINITION.

      CLASS-METHODS class_constructor.
      CLASS-METHODS
        get_flights_by_carrier
          IMPORTING
            i_carrier_id    TYPE /dmo/carrier_id
          RETURNING
            VALUE(r_result) TYPE tt_flights.

    PROTECTED SECTION.
    PRIVATE SECTION.


      DATA seats_max  TYPE /dmo/plane_seats_max.
      DATA seats_occ  TYPE /dmo/plane_seats_occupied.
      DATA seats_free TYPE i.

      DATA price      TYPE /dmo/flight_price.

      CONSTANTS currency TYPE /dmo/currency_code VALUE 'EUR'.



      TYPES: BEGIN OF st_flights_buffer,
               carrier_id     TYPE z98_pass_flight-carrier_id,
               connection_id  TYPE z98_pass_flight-connection_id,
               flight_date    TYPE z98_pass_flight-flight_date,
               plane_type_id  TYPE z98_pass_flight-plane_type_id,
               seats_max      TYPE z98_pass_flight-seats_max,
               seats_occupied TYPE z98_pass_flight-seats_occupied,
               seats_free     TYPE i,
               price          TYPE z98_pass_flight-price,
               currency_code  TYPE z98_pass_flight-currency_code,
             END OF st_flights_buffer.

*  CLASS-DATA: flights_buffer TYPE TABLE OF st_flights_buffer.
*  CLASS-DATA: flights_buffer
*                TYPE SORTED TABLE OF st_flights_buffer
*                WITH NON-UNIQUE KEY carrier_id connection_id flight_date.

      CLASS-DATA: flights_buffer
                    TYPE HASHED TABLE OF st_flights_buffer
                    WITH UNIQUE KEY carrier_id connection_id flight_date
                    WITH NON-UNIQUE SORTED KEY sk_carrier COMPONENTS carrier_id.

      "Analyzing Database Access with SQL Trace +
      TYPES:
        BEGIN OF st_connections_buffer,
          carrier_id      TYPE /dmo/carrier_id,
          connection_id   TYPE /dmo/connection_id,
          airport_from_id TYPE /dmo/airport_from_id,
          airport_to_id   TYPE /dmo/airport_to_id,
          departure_time  TYPE /dmo/flight_departure_time,
          arrival_time    TYPE /dmo/flight_departure_time,
          from_time_zone  TYPE timezone,
          to_time_zone    TYPE timezone,
          duration        TYPE i,
        END OF st_connections_buffer.

*  CLASS-DATA connections_buffer TYPE TABLE OF st_connections_buffer.
      CLASS-DATA connections_buffer
                   TYPE HASHED TABLE OF st_connections_buffer
                   WITH UNIQUE KEY carrier_id connection_id.


  ENDCLASS.

  CLASS lcl_passenger_flight IMPLEMENTATION.
    METHOD class_constructor.

*    SELECT
*     FROM Z98_AIRPORT
*   FIELDS airport_id, time_zone
*     INTO TABLE @DATA(airports).

      " Preload flight data into buffer
      SELECT
        FROM z98_pass_flight                            "#EC CI_NOWHERE
        FIELDS carrier_id, connection_id, flight_date, plane_type_id, seats_max, seats_occupied,
        seats_max - seats_occupied AS seats_free, price, currency_code
        INTO CORRESPONDING FIELDS OF TABLE @flights_buffer.

      DATA(today) = cl_abap_context_info=>get_system_date( ).

      " Preload connection data into buffer
      SELECT
        FROM /dmo/connection AS conn                    "#EC CI_NOWHERE
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
               from_apt~time_zone                       AS from_time_zone,
               to_apt~time_zone                         AS to_time_zone,
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

*   LOOP AT connections_buffer INTO DATA(connection).
*        CONVERT DATE today
*              TIME connection-departure_time
*              "TIME ZONE airports[ airport_id = connection-airport_from_id ]-time_zone
*              TIME ZONE connection-from_time_zone
*              INTO UTCLONG DATA(departure_utclong).
*
*        CONVERT DATE today
*              TIME connection-arrival_time
*              "TIME ZONE airports[ airport_id = connection-airport_to_id ]-time_zone
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


    ENDMETHOD.

    METHOD get_flights_by_carrier.

      " Check if data for this carrier is already loaded into the buffer
*    IF NOT line_exists( flights_buffer[ carrier_id = i_carrier_id ] ).
      IF NOT line_exists( flights_buffer[
                          KEY sk_carrier
                            COMPONENTS carrier_id = i_carrier_id ]
                      ).

        SELECT
          FROM z98_pass_flight
        FIELDS carrier_id, connection_id, flight_date,
               plane_type_id, seats_max, seats_occupied,
               seats_max - seats_occupied AS seats_free,
*           price,
               currency_conversion(
                 amount             = price,
                 source_currency    = currency_code,
                 target_currency    = @currency,
                 exchange_rate_date = flight_date,
                 on_error           =
                   @sql_currency_conversion=>c_on_error-set_to_null
                                  ) AS price,
*           currency_code
               @currency AS currency_code
         WHERE carrier_id    = @i_carrier_id
*     ORDER BY flight_date ASCENDING
*      INTO TABLE @flights_buffer.
          APPENDING TABLE @flights_buffer.

        " Maintain buffer integrity by sorting and removing possible DB duplicates
*      SORT flights_buffer BY carrier_id connection_id flight_date.
*      DELETE ADJACENT DUPLICATES FROM flights_buffer
*        COMPARING carrier_id connection_id flight_date.

      ENDIF.

*    LOOP AT flights_buffer INTO DATA(flight)
*    WHERE carrier_id = i_carrier_id.
*      APPEND NEW lcl_passenger_flight( i_carrier_id    = flight-carrier_id
*                                       i_connection_id = flight-connection_id
*                                       i_flight_date   = flight-flight_date )
*              TO r_result.
*    ENDLOOP.

*   r_result = VALUE #(
*               FOR flight IN flights_buffer
*                 WHERE ( carrier_id = i_carrier_id ) (
*                   NEW lcl_passenger_flight(
*                         i_carrier_id    = flight-carrier_id
*                         i_connection_id = flight-connection_id
*                         i_flight_date   = flight-flight_date )
*                                                     )
*             ).

      r_result = VALUE #(
               FOR <flight> IN flights_buffer
                 USING KEY sk_carrier
                 WHERE ( carrier_id = i_carrier_id ) (
                   NEW lcl_passenger_flight(
                         i_carrier_id    = <flight>-carrier_id
                         i_connection_id = <flight>-connection_id
                         i_flight_date   = <flight>-flight_date )
                                                     )
             ).

    ENDMETHOD.

    METHOD constructor.

      super->constructor(
             i_carrier_id    = i_carrier_id
             i_connection_id = i_connection_id
             i_flight_date   = i_flight_date ).

      " Read buffer
      TRY.
          DATA(flight_raw) = flights_buffer[ carrier_id    = i_carrier_id
                                             connection_id = i_connection_id
                                             flight_date   = i_flight_date ].

        CATCH cx_sy_itab_line_not_found.

          " Read from database if data not found in buffer
          SELECT SINGLE FROM z98_pass_flight
            FIELDS plane_type_id,
                   seats_max,
                   seats_occupied,
                   seats_max - seats_occupied AS seats_free,
*                   price,
                   currency_conversion(
                       amount             = price,
                       source_currency    = currency_code,
                       target_currency    = @currency,
                       exchange_rate_date = flight_date,
                       on_error           =
                         @sql_currency_conversion=>c_on_error-set_to_null
                                ) AS price,
*           currency_code
             @currency AS currency_code
            WHERE carrier_id    = @i_carrier_id
              AND connection_id = @i_connection_id
              AND flight_date   = @i_flight_date
            INTO CORRESPONDING FIELDS OF @flight_raw.

      ENDTRY.

      IF flight_raw IS NOT INITIAL.

        me->carrier_id    = i_carrier_id.
        me->connection_id = i_connection_id.
        me->flight_date   = i_flight_date.

        planetype = flight_raw-plane_type_id.
        seats_max = flight_raw-seats_max.
        seats_occ = flight_raw-seats_occupied.
        "seats_free = flight_raw-seats_max - flight_raw-seats_occupied.
        seats_free = flight_raw-seats_free. " Direkt aus SQL, da bereits berechnet
        price = flight_raw-price. " Direkt aus SQL, da bereits in EUR

* convert currencies
*      TRY.
*          cl_exchange_rates=>convert_to_local_currency(
*            EXPORTING
*              date              = me->flight_date
*              foreign_amount    = flight_raw-price
*              foreign_currency  = flight_raw-currency_code
*              local_currency    = me->currency
*            IMPORTING
*              local_amount      = me->price
*          ).
*        CATCH cx_exchange_rates.
*          price = flight_raw-price.
*      ENDTRY.


** Set connection details
*      SELECT SINGLE
*        FROM /dmo/connection
*      FIELDS airport_from_id, airport_to_id, departure_time, arrival_time
*       WHERE carrier_id    = @carrier_id
*         AND connection_id = @connection_id
*        INTO @connection_details .
*
*      connection_details-duration = connection_details-arrival_time
*                                  - connection_details-departure_time.

        " Try to read connection details from buffer
        DATA(connection_raw) = VALUE #( connections_buffer[
                                          carrier_id    = i_carrier_id
                                          connection_id = i_connection_id ] OPTIONAL ).

        " If not found in buffer, read from database
        IF connection_raw IS INITIAL.
          SELECT SINGLE
            FROM /dmo/connection
            FIELDS *
            WHERE carrier_id    = @i_carrier_id
              AND connection_id = @i_connection_id
            INTO CORRESPONDING FIELDS OF @connection_raw.

          " If found in database, insert into buffer for future use
          IF sy-subrc = 0.
            INSERT connection_raw INTO TABLE connections_buffer.
          ENDIF.
        ENDIF.

        " If connection data is available, calculate flight duration
        IF connection_raw IS NOT INITIAL.
          connection_details = CORRESPONDING #( connection_raw ).

          IF connection_details-duration IS INITIAL.

            " Simple duration calculation (HHMMSS format)
            connection_details-duration = connection_details-arrival_time
                                    - connection_details-departure_time.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDMETHOD.




    METHOD get_free_seats.
      r_result = me->seats_free.
    ENDMETHOD.


    METHOD get_description.

      r_result = super->get_description( ).

*    DATA txt TYPE string.
*
*    txt = 'Flight &carrid& &connid& on &date& from &from& to &to&'(005).
*
*    txt = replace( val = txt sub = '&carrid&' with = carrier_id ).
*    txt = replace( val = txt sub = '&connid&' with = connection_id ).
*    txt = replace( val = txt sub = '&date&' with = |{ flight_date DATE = USER }| ).
*    txt = replace( val = txt sub = '&from&' with = connection_details-airport_from_id ).
*    txt = replace( val = txt sub = '&to&' with = connection_details-airport_to_id ).
*
*    APPEND txt TO r_result.
*
**    APPEND |Flight { carrier_id } { connection_id } on { flight_date DATE = USER } | &&
**           |from { connection_details-airport_from_id } to { connection_details-airport_to_id } |
**           TO r_result.
*    APPEND |{ 'Planetype:'(006) }      { planetype  } | TO r_result.

      APPEND |{ 'Maximum Seats:'(007)  } { seats_max  } | TO r_result.
      APPEND |{ 'Occupied Seats:'(008) } { seats_occ  } | TO r_result.
      APPEND |{ 'Free Seats:'(009)     } { seats_free } | TO r_result.
      APPEND |{ 'Ticket Price:'(010)   } { price CURRENCY = currency } { currency } | TO r_result.

      APPEND |{ 'Duration:'(011)       } { connection_details-duration } { 'minutes'(012) }| TO r_result.

    ENDMETHOD.


  ENDCLASS.

  CLASS lcl_cargo_flight DEFINITION
      INHERITING FROM lcl_flight.

    PUBLIC SECTION.

      TYPES
         tt_flights TYPE STANDARD TABLE OF REF TO lcl_cargo_flight WITH DEFAULT KEY.

      METHODS constructor
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
          i_connection_id TYPE /dmo/connection_id
          i_flight_date   TYPE /dmo/flight_date.

      METHODS
        get_free_capacity
          RETURNING
            VALUE(r_result) TYPE z98_plane_actual_load. "/lrn/plane_actual_load.

*  METHODS get_description
*    RETURNING
*      VALUE(r_result) TYPE string_table.
      METHODS get_description REDEFINITION.

      CLASS-METHODS
        get_flights_by_carrier
          IMPORTING
            i_carrier_id    TYPE /dmo/carrier_id
          RETURNING
            VALUE(r_result) TYPE tt_flights.

    PROTECTED SECTION.
    PRIVATE SECTION.

      TYPES: BEGIN OF st_flights_buffer,
               carrier_id      TYPE /dmo/carrier_id,
               connection_id   TYPE /dmo/connection_id,
               flight_date     TYPE /dmo/flight_date,
               plane_type_id   TYPE /dmo/plane_type_id,
               maximum_load    TYPE z98_plane_max_load,
               actual_load     TYPE z98_plane_actual_load,
               load_unit       TYPE z98_plane_weight_unit,
               airport_from_id TYPE /dmo/airport_from_id,
               airport_to_id   TYPE /dmo/airport_to_id,
               departure_time  TYPE /dmo/flight_departure_time,
               arrival_time    TYPE /dmo/flight_arrival_time,
             END OF st_flights_buffer.

      TYPES tt_flights_buffer TYPE HASHED TABLE OF st_flights_buffer
                              WITH UNIQUE KEY carrier_id connection_id flight_date.

      DATA maximum_load TYPE z98_plane_max_load.
      DATA actual_load TYPE z98_plane_actual_load.
      DATA load_unit    TYPE z98_plane_weight_unit.

      CLASS-DATA flights_buffer TYPE tt_flights_buffer.

  ENDCLASS.

  CLASS lcl_cargo_flight IMPLEMENTATION.

    METHOD get_flights_by_carrier.

      SELECT
        FROM z98_cargo_flight
      FIELDS carrier_id, connection_id, flight_date,
             plane_type_id, maximum_load, actual_load, load_unit,
             airport_from_id, airport_to_id, departure_time, arrival_time
       WHERE carrier_id    = @i_carrier_id
       ORDER BY flight_date ASCENDING
        INTO CORRESPONDING FIELDS OF TABLE @flights_buffer.

*    LOOP AT flights_buffer INTO DATA(flight).
*      APPEND NEW lcl_cargo_flight( i_carrier_id    = flight-carrier_id
*                                   i_connection_id = flight-connection_id
*                                   i_flight_date   = flight-flight_date )
*              TO r_result.
*
*    ENDLOOP.

*     r_result = VALUE #( FOR flight IN flights_buffer
*                 WHERE ( carrier_id = i_carrier_id )
*                 ( NEW lcl_cargo_flight( i_carrier_id    = flight-carrier_id
*                                         i_connection_id = flight-connection_id
*                                         i_flight_date   = flight-flight_date ) ) ).

      r_result = VALUE #(
                FOR <flight> IN flights_buffer
                  WHERE ( carrier_id = i_carrier_id ) (
                    NEW lcl_cargo_flight(
                          i_carrier_id    = <flight>-carrier_id
                          i_connection_id = <flight>-connection_id
                          i_flight_date   = <flight>-flight_date )
                                                      )
              ).
    ENDMETHOD.

    METHOD constructor.

      super->constructor(
             i_carrier_id    = i_carrier_id
             i_connection_id = i_connection_id
             i_flight_date   = i_flight_date ).

      " Read buffer
      TRY.
          DATA(flight_raw) = flights_buffer[ carrier_id    = i_carrier_id
                                             connection_id = i_connection_id
                                             flight_date   = i_flight_date ].

        CATCH cx_sy_itab_line_not_found.
          " Read from database if data not found in buffer
          SELECT SINGLE
            FROM z98_cargo_flight
          FIELDS plane_type_id, maximum_load, actual_load, load_unit,
                 airport_from_id, airport_to_id, departure_time, arrival_time
           WHERE carrier_id    = @i_carrier_id
             AND connection_id = @i_connection_id
             AND flight_date   = @i_flight_date
            INTO CORRESPONDING FIELDS OF @flight_raw.
      ENDTRY.

      carrier_id    = i_carrier_id.
      connection_id = i_connection_id.
      flight_date   = i_flight_date.

      planetype = flight_raw-plane_type_id.
      maximum_load = flight_raw-maximum_load.
      actual_load = flight_raw-actual_load.
      load_unit = flight_raw-load_unit.

      connection_details = CORRESPONDING #( flight_raw ).

      connection_details-duration = me->connection_details-arrival_time
                                      - me->connection_details-departure_time.

    ENDMETHOD.

    METHOD get_free_capacity.
      r_result = maximum_load - actual_load.
    ENDMETHOD.

    METHOD get_description.

      r_result = super->get_description( ).

*    APPEND |Flight { carrier_id } { connection_id } on { flight_date DATE = USER } | &&
*           |from { connection_details-airport_from_id } to { connection_details-airport_to_id } |
*           TO r_result.
*    APPEND |Planetype:     { planetype } |                         TO r_result.

      APPEND |Maximum Load:  { maximum_load         } { load_unit }| TO r_result.
      APPEND |Free Capacity: { get_free_capacity( ) } { load_unit }| TO r_result.

    ENDMETHOD.

  ENDCLASS.

  CLASS lcl_carrier DEFINITION .

    PUBLIC SECTION.

      TYPES t_output TYPE string.
      TYPES tt_output TYPE STANDARD TABLE OF t_output
                      WITH NON-UNIQUE DEFAULT KEY.

      DATA carrier_id TYPE /dmo/carrier_id READ-ONLY.

      METHODS constructor
        IMPORTING
                  i_carrier_id TYPE /dmo/carrier_id
        RAISING   cx_abap_invalid_value
                  cx_abap_auth_check_exception.

      METHODS get_output RETURNING VALUE(r_result) TYPE tt_output.

      METHODS find_passenger_flight
        IMPORTING
          i_airport_from_id TYPE /dmo/airport_from_id
          i_airport_to_id   TYPE /dmo/airport_to_id
          i_from_date       TYPE /dmo/flight_date
          i_seats           TYPE i
        EXPORTING
          e_flight          TYPE REF TO lcl_flight
          e_days_later      TYPE i.

      METHODS find_cargo_flight
        IMPORTING
          i_airport_from_id TYPE /dmo/airport_from_id
          i_airport_to_id   TYPE /dmo/airport_to_id
          i_from_date       TYPE /dmo/flight_date
          i_cargo           TYPE z98_plane_actual_load
        EXPORTING
          e_flight          TYPE REF TO lcl_flight
          e_days_later      TYPE i.

    PROTECTED SECTION.
    PRIVATE SECTION.

      DATA name          TYPE /dmo/carrier_name .
      DATA currency_code TYPE /dmo/currency_code  ##NEEDED .

*      DATA passenger_flights TYPE lcl_passenger_flight=>tt_flights.
*      DATA cargo_flights     TYPE lcl_cargo_flight=>tt_flights.


      DATA flights  TYPE lcl_flight=>tab.
      DATA pf_count TYPE i.
      DATA cf_count TYPE i.

      METHODS get_average_free_seats
        RETURNING VALUE(r_result) TYPE i.

  ENDCLASS.

  CLASS lcl_carrier IMPLEMENTATION.

    METHOD constructor.

      me->carrier_id = i_carrier_id.

      SELECT SINGLE
      FROM /dmo/carrier
*    FIELDS  name, currency_code
      FIELDS concat_with_space( carrier_id, name, 1 ), currency_code
        WHERE carrier_id = @i_carrier_id
        INTO ( @me->name, @me->currency_code ).

*SELECT SINGLE
*    FROM /dmo/I_Carrier
*    FIELDS concat_with_space( AirlineID, Name, 1 ), CurrencyCode
*    WHERE AirlineID = @i_carrier_id
*    INTO ( @me->name, @me->currency_code ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_abap_invalid_value.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'Z98CARR'
        ID 'Z98CARRID' FIELD i_carrier_id
        ID 'ACTVT'     FIELD '03'.

      IF sy-subrc <> 0.
        "RAISE EXCEPTION TYPE cx_abap_auth_check_exception.
      ENDIF.

      "name = carrier_id && ` ` && name.

*      me->passenger_flights =
*          lcl_passenger_flight=>get_flights_by_carrier(
*                i_carrier_id    = i_carrier_id ).
*
*      me->cargo_flights =
*          lcl_cargo_flight=>get_flights_by_carrier(
*                i_carrier_id    = i_carrier_id ).

      DATA(passenger_flights) =
             lcl_passenger_flight=>get_flights_by_carrier(
                                     i_carrier_id = i_carrier_id ).
      pf_count = lines( passenger_flights ).

      DATA(cargo_flights) =
             lcl_cargo_flight=>get_flights_by_carrier(
                                     i_carrier_id = i_carrier_id ).
      cf_count = lines( cargo_flights ).

*      LOOP AT passenger_flights INTO DATA(passflight).
*        APPEND passflight TO flights.
*      ENDLOOP.
*
*      LOOP AT cargo_flights INTO DATA(cargoflight).
*        APPEND cargoflight TO flights.
*      ENDLOOP.

      flights = VALUE #( BASE flights
                   FOR pflight IN passenger_flights (
                     pflight
                                                    )
            ).

      flights = VALUE #( BASE flights
             FOR cflight IN cargo_flights (
               cflight
                                          )
            ).

    ENDMETHOD.

    METHOD get_output.

      APPEND |{ 'Carrier Name:'(001)       } { me->name } | TO r_result.
      APPEND |{ 'Passenger Flights:'(002)  } { pf_count } | TO r_result.
      APPEND |{ 'Average free seats:'(003) } { get_average_free_seats(  ) } | TO r_result.
      APPEND |{ 'Cargo Flights:'(004)      } { cf_count } | TO r_result.

    ENDMETHOD.

    METHOD find_cargo_flight.

      e_days_later = 99999999.

*      LOOP AT me->cargo_flights INTO DATA(flight)
       LOOP AT me->flights INTO DATA(flight)
        WHERE table_line->flight_date >= i_from_date
         AND table_line IS INSTANCE OF lcl_cargo_flight.

        DATA(connection_details) = flight->get_connection_details(  ).

        IF connection_details-airport_from_id = i_airport_from_id
         AND connection_details-airport_to_id = i_airport_to_id
*         AND flight->get_free_capacity(  ) >= i_cargo.
         AND CAST lcl_cargo_flight( flight )->get_free_capacity(  ) >= i_cargo.

*        DATA(days_later) =  i_from_date - flight->flight_date.           " Hier der Fehler aus Aufgabe 3
          DATA(days_later) =  flight->flight_date - i_from_date.           " Hier ohne Fehler

          IF days_later < e_days_later. "earlier than previous one?
            e_flight = flight.
            e_days_later = days_later.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDMETHOD.

    METHOD find_passenger_flight.

      e_days_later = 99999999.

*      LOOP AT me->passenger_flights INTO DATA(flight)
       LOOP AT me->flights INTO DATA(flight)
        WHERE table_line->flight_date >= i_from_date
          AND table_line IS INSTANCE OF lcl_passenger_flight.

        DATA(connection_details) = flight->get_connection_details(  ).

        IF connection_details-airport_from_id = i_airport_from_id
         AND connection_details-airport_to_id = i_airport_to_id
*         AND flight->get_free_seats( ) >= i_seats.
         AND CAST lcl_passenger_flight( flight )->get_free_seats( ) >= i_seats.
          DATA(days_later) = flight->flight_date - i_from_date.

          IF days_later < e_days_later. "earlier than previous one?
            e_flight = flight.
            e_days_later = days_later.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDMETHOD.

    METHOD get_average_free_seats.
**    DATA total TYPE i.
**
**    LOOP AT passenger_flights INTO DATA(flight).
**
**      total = total + flight->get_free_seats( ).
**
**    ENDLOOP.
**
**    r_result = total / lines( passenger_flights ).
*
**    SELECT FROM z98_pass_flight
**      FIELDS SUM( seats_max - seats_occupied ) AS sum,
**             COUNT(*)                          AS count
**      WHERE carrier_id = @carrier_id
**      INTO @DATA(aggregates).
**
**    IF aggregates-count > 0.
**      r_result = aggregates-sum / aggregates-count.
**    ELSE.
**      r_result = 0.
**    ENDIF.
*
*    SELECT FROM z98_pass_flight
*      FIELDS CAST( AVG( seats_max - seats_occupied ) AS INT4 )
*      WHERE carrier_id = @carrier_id
*      INTO @r_result.

*      r_result = REDUCE #(
*               INIT i = 0
*               FOR flight IN passenger_flights
*               NEXT i = i + flight->get_free_seats( )
*             )
*             / lines( passenger_flights ).

        r_result = REDUCE #(
                 INIT i = 0
                 FOR flight IN flights
                 WHERE ( table_line IS INSTANCE OF lcl_passenger_flight )
                 NEXT i += CAST lcl_passenger_flight( flight )->get_free_seats( )
                       ) / pf_count.
    ENDMETHOD.
  ENDCLASS.
