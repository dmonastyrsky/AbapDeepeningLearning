CLASS zcl_98_da_fill_airports DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_da_fill_airports IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA lt_airports TYPE STANDARD TABLE OF z98_airport WITH EMPTY KEY.
    DATA lv_count TYPE i.

    TRY.
        out->write( |Step 1: Cleaning and fetching base data...| ).

        " 1. Clear your custom table before refilling
        DELETE FROM z98_airport.

        IF sy-subrc <> 0.
          out->write( |Warning: Could not clear Z98_AIRPORT table.| ).
        ENDIF.

        " 2. Fetch data from the original demo table
        SELECT FROM /dmo/airport
          FIELDS
            client,
            airport_id,
            name,
            city,
            country
          INTO CORRESPONDING FIELDS OF TABLE @lt_airports.

        lv_count = lines( lt_airports ).
        out->write( |Step 2: Fetched { lv_count } records from /DMO/AIRPORT.| ).

        IF lv_count = 0.
          out->write( |No data found in /DMO/AIRPORT table.| ).
          RETURN.
        ENDIF.

        out->write( |Step 3: Populating time zones based on country...| ).

        " 3. Fill the 'time_zone' field based on the country code
        LOOP AT lt_airports ASSIGNING FIELD-SYMBOL(<fs_airport>).

          CASE <fs_airport>-country.

              " --- EUROPE ---
              " Central European Time (UTC+1)
            WHEN 'DE' OR 'FR' OR 'AT' OR 'CH' OR 'NL' OR 'IT' OR 'BE' OR 'LU' OR 'CZ' OR 'SK' OR 'HU' OR 'PL' OR 'RO' OR 'SE' OR 'NO' OR 'DK'.
              <fs_airport>-time_zone = 'UTC+1'.

              " Spain & Canary Islands
            WHEN 'ES'.
              CASE <fs_airport>-airport_id.
                WHEN 'ACE' OR 'TFN' OR 'TFS' OR 'LPA'. " Canary Islands
                  <fs_airport>-time_zone = 'UTC'.
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC+1'.
              ENDCASE.

              " British Isles, Iceland & Portugal
            WHEN 'GB' OR 'IE' OR 'IS' OR 'PT'.
              <fs_airport>-time_zone = 'UTC'.

              " Eastern Europe & Finland (UTC+2)
            WHEN 'UA' OR 'FI' OR 'BY' OR 'BG' OR 'GR' OR 'RS' OR 'HR' OR 'SI' OR 'LT' OR 'LV' OR 'EE' OR 'MT' OR 'CY'.
              <fs_airport>-time_zone = 'UTC+2'.

              " Turkey & Russia (Moscow/West)
            WHEN 'TR'.
              <fs_airport>-time_zone = 'UTC+3'.

            WHEN 'RU'.
              CASE <fs_airport>-airport_id.
                WHEN 'SVO' OR 'DME' OR 'VKO'.
                  <fs_airport>-time_zone = 'UTC+3'. " Moscow Time
                WHEN 'OVB'.
                  <fs_airport>-time_zone = 'UTC+7'. " Novosibirsk Time
                WHEN 'VVO'.
                  <fs_airport>-time_zone = 'UTC+10'. " Vladivostok Time
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC+3'.
              ENDCASE.

              " --- NORTH AMERICA ---
            WHEN 'US'.
              CASE <fs_airport>-airport_id.
                WHEN 'JFK' OR 'LGA' OR 'EWR' OR 'BOS' OR 'MIA' OR 'PHL' OR 'DCA' OR 'IAD' OR 'BWI'.
                  <fs_airport>-time_zone = 'UTC-5'. " Eastern Standard Time
                WHEN 'ORD' OR 'MDW' OR 'DFW' OR 'IAH' OR 'BNA' OR 'HOU' OR 'MCI'.
                  <fs_airport>-time_zone = 'UTC-6'. " Central Standard Time
                WHEN 'DEN' OR 'PHX' OR 'SLC' OR 'ABQ' OR 'ELP'.
                  <fs_airport>-time_zone = 'UTC-7'. " Mountain Standard Time
                WHEN 'SFO' OR 'LAX' OR 'SEA' OR 'SAN' OR 'LAS' OR 'PDX' OR 'OAK' OR 'SJC'.
                  <fs_airport>-time_zone = 'UTC-8'. " Pacific Standard Time
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC-5'.
              ENDCASE.

            WHEN 'CA'.
              CASE <fs_airport>-airport_id.
                WHEN 'YYZ' OR 'YUL' OR 'YOW' OR 'YHZ'.
                  <fs_airport>-time_zone = 'UTC-5'. " Eastern
                WHEN 'YYC' OR 'YEG'.
                  <fs_airport>-time_zone = 'UTC-7'. " Mountain
                WHEN 'YVR'.
                  <fs_airport>-time_zone = 'UTC-8'. " Pacific
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC-5'.
              ENDCASE.

              " Mexico & Central America
            WHEN 'MX' OR 'CR' OR 'PA' OR 'HN' OR 'NI' OR 'GT' OR 'SV' OR 'BZ'.
              <fs_airport>-time_zone = 'UTC-6'.

              " --- SOUTH AMERICA ---
            WHEN 'BR'.
              CASE <fs_airport>-airport_id.
                WHEN 'MAO'.
                  <fs_airport>-time_zone = 'UTC-4'. " Amazon Time
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC-3'. " Brasilia Time
              ENDCASE.

            WHEN 'AR' OR 'CL' OR 'UY' OR 'BO' OR 'PY' OR 'GY' OR 'SR' OR 'GF'.
              <fs_airport>-time_zone = 'UTC-3'.

            WHEN 'CO' OR 'EC' OR 'PE' OR 'VE'.
              <fs_airport>-time_zone = 'UTC-5'.

              " --- ASIA & MIDDLE EAST ---
            WHEN 'SA' OR 'AE' OR 'KW' OR 'QA' OR 'BH' OR 'OM' OR 'YE'.
              " Hard-fix for GCJ (Johannesburg) if it has the wrong country code 'SA'
              IF <fs_airport>-airport_id = 'GCJ'.
                <fs_airport>-country = 'ZA'.
                <fs_airport>-time_zone = 'UTC+2'.
              ELSE.
                <fs_airport>-time_zone = 'UTC+3'.
              ENDIF.

            WHEN 'IL' OR 'SY' OR 'IQ' OR 'JO' OR 'LB'.
              <fs_airport>-time_zone = 'UTC+2'.

            WHEN 'IR' OR 'AZ' OR 'TM' OR 'UZ' OR 'KG' OR 'TJ' OR 'AF'.
              <fs_airport>-time_zone = 'UTC+3'.

            WHEN 'KZ'.
              <fs_airport>-time_zone = 'UTC+5'. " Kazakhstan Unified Time

            WHEN 'IN' OR 'BD' OR 'LK' OR 'NP' OR 'PK'.
              <fs_airport>-time_zone = 'UTC+5.5'. " Indian Standard Time

            WHEN 'TH' OR 'VN' OR 'KH' OR 'LA'.
              <fs_airport>-time_zone = 'UTC+7'.

            WHEN 'MY' OR 'SG' OR 'BN' OR 'PH' OR 'CN' OR 'TW'.
              <fs_airport>-time_zone = 'UTC+8'.

            WHEN 'ID'.
              CASE <fs_airport>-airport_id.
                WHEN 'CGK' OR 'BDO' OR 'SUB'.
                  <fs_airport>-time_zone = 'UTC+7'. " Western Indonesian Time
                WHEN 'DPS' OR 'LOP'.
                  <fs_airport>-time_zone = 'UTC+8'. " Central Indonesian Time
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC+7'.
              ENDCASE.

            WHEN 'JP' OR 'KR'.
              <fs_airport>-time_zone = 'UTC+9'.

              " --- OCEANIA ---
            WHEN 'AU'.
              CASE <fs_airport>-airport_id.
                WHEN 'SYD' OR 'MEL' OR 'BNE' OR 'CBR'.
                  <fs_airport>-time_zone = 'UTC+10'. " Australian Eastern Time
                WHEN 'PER'.
                  <fs_airport>-time_zone = 'UTC+8'. " Australian Western Time
                WHEN 'ADL' OR 'ASP'.
                  <fs_airport>-time_zone = 'UTC+9'. " Australian Central Time (approx)
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'UTC+10'.
              ENDCASE.

            WHEN 'NZ'.
              <fs_airport>-time_zone = 'UTC+12'.

              " --- AFRICA ---
            WHEN 'EG' OR 'LY' OR 'SD'.
              <fs_airport>-time_zone = 'UTC+2'.

            WHEN 'DZ' OR 'TN' OR 'MA'.
              <fs_airport>-time_zone = 'UTC+1'.

              " Southern Africa (ZA = South Africa, ZW = Zimbabwe)
            WHEN 'ZA' OR 'BW' OR 'LS' OR 'SZ' OR 'ZW' OR 'MZ' OR 'MW' OR 'ZM'.
              <fs_airport>-time_zone = 'UTC+2'.

              " East Africa
            WHEN 'ET' OR 'KE' OR 'UG' OR 'TZ'.
              <fs_airport>-time_zone = 'UTC+3'.

              " West & Central Africa
            WHEN 'NG' OR 'GH' OR 'CI' OR 'SN' OR 'ML' OR 'BJ' OR 'BF' OR 'GM' OR 'GN' OR 'GW' OR 'LR' OR 'MR' OR 'SL' OR 'TG' OR 'CG' OR 'CD' OR 'AO' OR 'CM' OR 'GA' OR 'GQ' OR 'ST' OR 'CF'.
              <fs_airport>-time_zone = 'UTC'.

              " Caribbean & Atlantic
            WHEN 'CU' OR 'DO' OR 'HT' OR 'PR' OR 'JM' OR 'TT' OR 'BB' OR 'BS' OR 'AG' OR 'KN' OR 'LC' OR 'VC' OR 'VG' OR 'VI' OR 'AI' OR 'DM' OR 'GD' OR 'MS' OR 'KY' OR 'TK' OR 'BM' OR 'CV' OR 'SH' OR 'GL' OR 'FO'.
              <fs_airport>-time_zone = 'UTC-5'.

            WHEN OTHERS.
              <fs_airport>-time_zone = 'UTC'.

          ENDCASE.

        ENDLOOP.


        " 4. Insert enriched data into your custom table
        INSERT z98_airport FROM TABLE @lt_airports.

        IF sy-subrc = 0.
          out->write( |✓ Success! { sy-dbcnt } records populated in Z98_AIRPORT.| ).
        ELSE.
          out->write( |✗ Error: Could not populate the table (Return Code: { sy-subrc }).| ).
          RETURN.
        ENDIF.

        " 5. Verify all time zones exist in the system
        out->write( |Step 4: Verifying time zones in the system...| ).

        DATA lt_verify_airports TYPE STANDARD TABLE OF z98_airport WITH EMPTY KEY.
        DATA lt_timezones TYPE STANDARD TABLE OF string WITH EMPTY KEY.
        DATA lv_date TYPE d.
        DATA lv_time TYPE t.
        DATA lv_tz_valid TYPE i VALUE 0.
        DATA lv_tz_invalid TYPE i VALUE 0.
        DATA lt_invalid_tz TYPE STANDARD TABLE OF string WITH EMPTY KEY.

        " Fetch all records with their time zones
        SELECT * FROM z98_airport INTO TABLE @lt_verify_airports.

        " Collect unique time zones
        LOOP AT lt_verify_airports ASSIGNING FIELD-SYMBOL(<fs_verify>).
          IF <fs_verify>-time_zone IS NOT INITIAL.
            APPEND <fs_verify>-time_zone TO lt_timezones.
          ENDIF.
        ENDLOOP.

        SORT lt_timezones.
        DELETE ADJACENT DUPLICATES FROM lt_timezones.

        out->write( |===== TIMEZONE VALIDATION REPORT =====| ).
        out->write( |Total unique time zones to verify: { lines( lt_timezones ) }| ).

        " Verify each time zone
        LOOP AT lt_timezones ASSIGNING FIELD-SYMBOL(<fs_tz>).
          CLEAR: lv_date, lv_time.

          TRY.
              CONVERT UTCLONG utclong_current( )
                      TIME ZONE <fs_tz>
                      INTO DATE lv_date TIME lv_time.

              IF sy-subrc = 0.
                out->write( |✓ { <fs_tz> } - Valid (Sample: { lv_date } { lv_time })| ).
                lv_tz_valid = lv_tz_valid + 1.
              ELSE.
                out->write( |✗ { <fs_tz> } - Invalid (Return Code: { sy-subrc })| ).
                lv_tz_invalid = lv_tz_invalid + 1.
                APPEND <fs_tz> TO lt_invalid_tz.
              ENDIF.

            CATCH cx_root INTO DATA(lx_tz_error).
              out->write( |✗ { <fs_tz> } - Error: { lx_tz_error->get_text( ) }| ).
              lv_tz_invalid = lv_tz_invalid + 1.
              APPEND <fs_tz> TO lt_invalid_tz.
          ENDTRY.
        ENDLOOP.

        out->write( |===== VERIFICATION SUMMARY =====| ).
        out->write( |Valid time zones: { lv_tz_valid }| ).
        out->write( |Invalid time zones: { lv_tz_invalid }| ).

        IF lv_tz_invalid > 0.
          out->write( |⚠️  WARNING: The following time zones are not valid in the system:| ).
          LOOP AT lt_invalid_tz ASSIGNING FIELD-SYMBOL(<fs_invalid>).
            out->write( |  - { <fs_invalid> }| ).
          ENDLOOP.
          out->write( |Please check system timezone configuration!| ).
        ELSE.
          out->write( |✓ All time zones are valid and working correctly!| ).
        ENDIF.

      CATCH cx_root INTO DATA(lx_error).
        out->write( |✗ Exception occurred: { lx_error->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
