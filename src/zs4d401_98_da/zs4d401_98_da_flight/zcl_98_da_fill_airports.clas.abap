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
            " Europe - CET (Central European Time)
            WHEN 'DE' OR 'FR' OR 'AT' OR 'CH' OR 'NL' OR 'IT' OR 'BE' OR 'LU' OR 'ES' OR 'CZ' OR 'SK' OR 'HU' OR 'RO' OR 'PT'.
              <fs_airport>-time_zone = 'CET'.       " Central European Time (UTC+1)

            " British Isles - Use WET (Western European Time)
            WHEN 'GB' OR 'IE' OR 'IS'.
              <fs_airport>-time_zone = 'WET'.       " Western European Time (UTC+0)

            " Nordic Countries - CET
            WHEN 'SE' OR 'NO' OR 'DK' OR 'FI'.
              <fs_airport>-time_zone = 'CET'.       " Central European Time (UTC+1)

            " Eastern Europe - EET (Eastern European Time)
            WHEN 'PL' OR 'UA' OR 'BY' OR 'RU' OR 'BG' OR 'GR' OR 'RS' OR 'HR' OR 'SI' OR 'LT' OR 'LV' OR 'EE' OR 'MT' OR 'CY'.
              <fs_airport>-time_zone = 'EET'.       " Eastern European Time (UTC+2)

            " North America - EST/CST/PST
            WHEN 'US'.
              CASE <fs_airport>-city.
                WHEN 'New York' OR 'Boston' OR 'Miami' OR 'Philadelphia' OR 'Washington'.
                  <fs_airport>-time_zone = 'EST'.   " Eastern Standard Time (UTC-5)
                WHEN 'Chicago' OR 'Dallas' OR 'Houston' OR 'Denver'.
                  <fs_airport>-time_zone = 'CST'.   " Central Standard Time (UTC-6)
                WHEN 'Phoenix' OR 'Salt Lake City' OR 'Albuquerque'.
                  <fs_airport>-time_zone = 'MST'.   " Mountain Standard Time (UTC-7)
                WHEN 'Los Angeles' OR 'San Francisco' OR 'Seattle' OR 'San Diego' OR 'Las Vegas' OR 'Portland'.
                  <fs_airport>-time_zone = 'PST'.   " Pacific Standard Time (UTC-8)
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'EST'.   " Default to Eastern
              ENDCASE.

            " Canada
            WHEN 'CA'.
              CASE <fs_airport>-city.
                WHEN 'Toronto' OR 'Montreal' OR 'Ottawa' OR 'Halifax'.
                  <fs_airport>-time_zone = 'EST'.   " Eastern
                WHEN 'Calgary' OR 'Edmonton' OR 'Vancouver'.
                  <fs_airport>-time_zone = 'PST'.   " Pacific
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'EST'.
              ENDCASE.

            " Mexico & Central America
            WHEN 'MX' OR 'CR' OR 'PA' OR 'HN' OR 'NI' OR 'GT' OR 'SV' OR 'BZ'.
              <fs_airport>-time_zone = 'CST'.       " Central Standard Time (UTC-6)

            " South America - Use EST/CST as available equivalents
            WHEN 'BR' OR 'AR' OR 'CL' OR 'UY' OR 'BO' OR 'PY' OR 'GY' OR 'SR' OR 'GF'.
              <fs_airport>-time_zone = 'EST'.       " Fallback to EST for South America

            WHEN 'CO' OR 'EC' OR 'PE' OR 'VE'.
              <fs_airport>-time_zone = 'CST'.       " Fallback to CST

            " Middle East & Central Asia
            WHEN 'SA' OR 'AE' OR 'KW' OR 'QA' OR 'BH' OR 'OM' OR 'YE'.
              <fs_airport>-time_zone = 'AST'.       " Arabia Standard Time (UTC+3)
            WHEN 'IL' OR 'TR' OR 'SY' OR 'IQ' OR 'JO' OR 'LB'.
              <fs_airport>-time_zone = 'EET'.       " Eastern European Time (UTC+2)
            WHEN 'IR' OR 'AZ' OR 'TM' OR 'UZ' OR 'KZ' OR 'KG' OR 'TJ' OR 'AF'.
              <fs_airport>-time_zone = 'AST'.       " Arabia Standard Time as fallback (UTC+3)

            " South Asia
            WHEN 'IN' OR 'BD' OR 'LK' OR 'NP' OR 'PK'.
              <fs_airport>-time_zone = 'IST'.       " Indian Standard Time (UTC+5:30)

            " Southeast Asia - Use CST for Malaysia/Singapore area
            WHEN 'TH' OR 'VN' OR 'KH' OR 'LA' OR 'MY' OR 'SG' OR 'BN' OR 'ID' OR 'PH'.
              <fs_airport>-time_zone = 'CST'.       " China Standard Time (UTC+8)

            " East Asia
            WHEN 'JP' OR 'CN' OR 'KR' OR 'TW'.
              <fs_airport>-time_zone = 'CST'.       " China Standard Time (UTC+8)

            " Oceania - Use PST/WET as fallbacks
            WHEN 'AU' OR 'NZ'.
              CASE <fs_airport>-city.
                WHEN 'Sydney' OR 'Melbourne' OR 'Brisbane' OR 'Canberra' OR 'Perth'.
                  <fs_airport>-time_zone = 'PST'.   " Fallback for Australian Eastern
                WHEN OTHERS.
                  <fs_airport>-time_zone = 'PST'.
              ENDCASE.

            " Africa - North
            WHEN 'EG' OR 'LY' OR 'SD' OR 'DZ' OR 'TN' OR 'MA'.
              <fs_airport>-time_zone = 'EET'.       " Eastern European Time (UTC+2)

            " Africa - South
            WHEN 'ZA' OR 'BW' OR 'LS' OR 'SZ'.
              <fs_airport>-time_zone = 'EET'.       " Use EET as fallback

            " Africa - West & Central
            WHEN 'NG' OR 'GH' OR 'CI' OR 'SN' OR 'ML' OR 'BJ' OR 'BF' OR 'GM' OR 'GN' OR 'GW' OR 'LR' OR 'MR' OR 'SL' OR 'TG' OR 'CG' OR 'CD' OR 'AO' OR 'CM' OR 'GA' OR 'GQ' OR 'ST' OR 'CF'.
              <fs_airport>-time_zone = 'WET'.       " Western European Time (UTC+0)

            " Africa - East
            WHEN 'ET' OR 'KE' OR 'UG' OR 'TZ' OR 'MZ' OR 'MW' OR 'ZM' OR 'ZW'.
              <fs_airport>-time_zone = 'EET'.       " Eastern European Time (UTC+2)

            " Caribbean & Atlantic
            WHEN 'CU' OR 'DO' OR 'HT' OR 'PR' OR 'JM' OR 'TT' OR 'BB' OR 'BS' OR 'AG' OR 'KN' OR 'LC' OR 'VC' OR 'VG' OR 'VI' OR 'AI' OR 'DM' OR 'GD' OR 'MS' OR 'KY' OR 'TK' OR 'BM' OR 'CV' OR 'SH' OR 'GL' OR 'FO'.
              <fs_airport>-time_zone = 'EST'.       " Eastern Standard Time (UTC-5)

            " Default fallback
            WHEN OTHERS.
              <fs_airport>-time_zone = 'WET'.       " Western European Time (UTC+0) - neutral fallback
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
