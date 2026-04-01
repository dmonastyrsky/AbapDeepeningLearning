CLASS zcl_98_da_fill_pass_flight DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_98_da_fill_pass_flight IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA(lv_source_table) = '/DMO/FLIGHT'.
    DATA(lv_target_table) = 'Z98_PASS_FLIGHT'.

    DATA lt_pass_flights TYPE STANDARD TABLE OF z98_pass_flight WITH EMPTY KEY.

    out->write( |Step 1: Reading data from { lv_source_table }...| ).

    SELECT FROM (lv_source_table)
      FIELDS
        client, carrier_id, connection_id, flight_date,
        price, currency_code, plane_type_id, seats_max, seats_occupied
      INTO CORRESPONDING FIELDS OF TABLE @lt_pass_flights.

    out->write( |Step 2: Preparing technical RAP fields (Admin Data)...| ).

    GET TIME STAMP FIELD DATA(lv_timestamp).

    LOOP AT lt_pass_flights ASSIGNING FIELD-SYMBOL(<fs_pass_flights>).
      <fs_pass_flights>-local_created_by      = sy-uname.
      <fs_pass_flights>-local_created_at      = lv_timestamp.
      <fs_pass_flights>-local_last_changed_by = sy-uname.
      <fs_pass_flights>-local_last_changed_at = lv_timestamp.
      <fs_pass_flights>-last_changed_at       = lv_timestamp.
    ENDLOOP.

    DELETE FROM (lv_target_table).

    INSERT (lv_target_table) FROM TABLE @lt_pass_flights.

    IF sy-subrc = 0.
      out->write( |SUCCESS: { lines( lt_pass_flights ) } rows copied to { lv_target_table }.| ).
    ELSE.
      out->write( |ERROR: Could not insert data. Check if table { lv_target_table } is active.| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
