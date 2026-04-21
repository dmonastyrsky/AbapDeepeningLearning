
CLASS lcl_flights DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
    METHODS access_standard.
    METHODS access_sorted.
    METHODS access_hashed.

  PRIVATE SECTION.
    DATA standard_table    TYPE STANDARD TABLE OF z98_flights  WITH NON-UNIQUE KEY carrier_id connection_id flight_date.
    DATA sorted_table      TYPE SORTED TABLE OF z98_flights WITH NON-UNIQUE KEY carrier_id connection_id flight_date.
    DATA hashed_table      TYPE HASHED TABLE OF z98_flights WITH UNIQUE KEY carrier_id connection_id flight_date.

    DATA key_carrier_id    TYPE /dmo/carrier_id.
    DATA key_connection_id TYPE /dmo/connection_id.
    DATA key_date          TYPE /dmo/flight_date.

    METHODS set_line_to_read.

ENDCLASS.


CLASS lcl_flights IMPLEMENTATION.
  METHOD access_hashed.
    DATA(result) = hashed_table[ carrier_Id    = key_carrier_id
                                 connection_Id = key_connection_id
                                 flight_date   = key_date ].
  ENDMETHOD.

  METHOD access_sorted.
    DATA(result) = sorted_table[ carrier_Id    = key_carrier_id
                                 connection_Id = key_connection_id
                                 flight_date   = key_date ].
  ENDMETHOD.

  METHOD constructor.
    SELECT FROM z98_flights FIELDS * INTO TABLE @standard_table.
    SELECT FROM z98_flights FIELDS * INTO TABLE @sorted_table.
    SELECT FROM z98_flights FIELDS * INTO TABLE @hashed_table.

    set_line_to_read( ).
  ENDMETHOD.

  METHOD access_standard.
    DATA(result) = standard_table[ carrier_Id    = key_carrier_id
                                   connection_Id = key_connection_id
                                   flight_date   = key_date ].
  ENDMETHOD.

  METHOD set_line_to_read.
    DATA(line) = standard_table[ CONV i( lines( standard_table ) * '0.65' ) ].
    key_carrier_id = line-carrier_Id.
    key_connection_Id = line-connection_id.
    key_date = line-flight_date.
  ENDMETHOD.
ENDCLASS.
