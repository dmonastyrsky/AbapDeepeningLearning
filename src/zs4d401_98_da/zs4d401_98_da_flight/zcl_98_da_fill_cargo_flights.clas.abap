CLASS zcl_98_da_fill_cargo_flights DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_da_fill_cargo_flights IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA lt_cargo_flights TYPE STANDARD TABLE OF z98_cargo_flight WITH EMPTY KEY.

    out->write( |Step 1: Reading data ...| ).

    " 1. Clear existing data
    DELETE FROM z98_cargo_flight.

    " 2. Clean SELECT without logic - just fetching raw data
    SELECT FROM /dmo/flight AS fl
      INNER JOIN /dmo/connection AS conn
        ON  fl~carrier_id    = conn~carrier_id
        AND fl~connection_id = conn~connection_id
      FIELDS
        fl~client,
        fl~carrier_id,
        fl~connection_id,
        fl~flight_date,
        fl~plane_type_id,
        conn~airport_from_id,
        conn~airport_to_id,
        conn~departure_time,
        conn~arrival_time
      INTO CORRESPONDING FIELDS OF TABLE @lt_cargo_flights.

    " 3. Processing all fields in LOOP (Logic + Technical fields)
    GET TIME STAMP FIELD DATA(lv_timestamp).

    " Correctly get a numeric seed for the random generator
    DATA(lv_seed) = cl_abap_context_info=>get_system_time( ).
    DATA(lo_rand) = cl_abap_random_int=>create(
      seed = conv i( lv_seed )
      min  = 70
      max  = 98
    ).

    LOOP AT lt_cargo_flights ASSIGNING FIELD-SYMBOL(<fs_flight>).

      " Set maximum_load based on plane_type_id
      CASE <fs_flight>-plane_type_id.
        WHEN '747-400'.
          <fs_flight>-maximum_load = 140000.
        WHEN 'A340-300'.
          <fs_flight>-maximum_load = 45000.
        WHEN 'A330-300'.
          <fs_flight>-maximum_load = 40000.
        WHEN 'A310-300'.
          <fs_flight>-maximum_load = 33000.
        WHEN '767-200'.
          <fs_flight>-maximum_load = 45000.
        WHEN 'A321-200'.
          <fs_flight>-maximum_load = 28000.
        WHEN 'A320-200'.
          <fs_flight>-maximum_load = 25000.
        WHEN 'A319-100'.
          <fs_flight>-maximum_load = 18000.
        WHEN '737-700'.
          <fs_flight>-maximum_load = 20000.
        WHEN OTHERS.
          <fs_flight>-maximum_load = 30000.
      ENDCASE.

      " Calculate actual_load (percentage of maximum)
      <fs_flight>-actual_load = ( <fs_flight>-maximum_load * lo_rand->get_next( ) ) / 100.

      " Set Load Unit
      <fs_flight>-load_unit = 'KG'.

      " Fill ALL technical/administrative fields
      <fs_flight>-local_created_by      = sy-uname.
      <fs_flight>-local_created_at      = lv_timestamp.
      <fs_flight>-local_last_changed_by = sy-uname.
      <fs_flight>-local_last_changed_at = lv_timestamp.
      <fs_flight>-last_changed_at       = lv_timestamp.

    ENDLOOP.

    " 4. Final insertion of all processed rows
    INSERT z98_cargo_flight FROM TABLE @lt_cargo_flights.

    IF sy-subrc = 0.
      out->write( |Done. { sy-dbcnt } records populated with full data set.| ).
    ELSE.
      out->write( |ERROR: Could not insert data.| ).
    ENDIF.

  ENDMETHOD.


ENDCLASS.
