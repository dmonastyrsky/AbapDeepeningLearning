CLASS zcl_98_08_1_sql_date_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_08_1_sql_date_process IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT FROM /dmo/travel
         FIELDS begin_date,
                end_date,
                is_valid( begin_date  )              AS valid,

                add_days( begin_date, 7 )            AS add_7_days,
                add_months(  begin_date, 3 )         AS add_3_months,
                days_between( begin_date, end_date ) AS duration,

                weekday(  begin_date  )              AS weekday,
                extract_month(  begin_date )         AS month,
                dayname(  begin_date )               AS day_name

          WHERE customer_id = '000594'
            "AND days_between( begin_date, end_date ) > 10

           INTO TABLE @DATA(result).

    out->write(
      EXPORTING
        data   = result
        name   = 'RESULT'
    ).

  ENDMETHOD.
ENDCLASS.
