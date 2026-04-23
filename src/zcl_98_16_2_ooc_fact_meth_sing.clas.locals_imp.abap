CLASS lcl_connection DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING airlineid        TYPE /dmo/carrier_id
                connectionnumber TYPE /dmo/connection_id
                fromAirport      TYPE /dmo/airport_from_id
                toAirport        TYPE /dmo/airport_to_id.

    CLASS-METHODS get_connection
      IMPORTING airlineId            TYPE /dmo/carrier_id
                connectionNumber     TYPE /dmo/connection_id
      RETURNING VALUE(ro_connection) TYPE REF TO lcl_connection.

    CLASS-METHODS get_n_o_connections
      RETURNING VALUE(rv_count) TYPE i.

    METHODS get_attributes
      RETURNING VALUE(rv_attributes) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ts_instance,
             airlineId        TYPE /dmo/carrier_id,
             connectionNumber TYPE /dmo/connection_id,
             object           TYPE REF TO lcl_connection,
           END OF ts_instance,
           tt_instances TYPE HASHED TABLE OF ts_instance
                          WITH UNIQUE KEY airlineId ConnectionNumber.

    DATA AirlineId        TYPE /dmo/carrier_id.
    DATA ConnectionNumber TYPE /dmo/connection_id.
    DATA fromAirport      TYPE /dmo/airport_from_id.
    DATA toAirport        TYPE /dmo/airport_to_id.

    CLASS-DATA connections TYPE tt_instances.
ENDCLASS.

CLASS lcl_connection IMPLEMENTATION.

  METHOD constructor.
    me->airlineid        = airlineid.
    me->connectionnumber = connectionnumber.
    me->fromAirport      = fromairport.
    me->toAirport        = toairport.
  ENDMETHOD.

  METHOD get_connection.
    " Перевірка, чи об'єкт уже є в кеші (Hashed Table)
    ASSIGN connections[ airlineid        = airlineid
                        connectionnumber = connectionnumber ] TO FIELD-SYMBOL(<fs_instance>).

    IF sy-subrc <> 0.
      " Якщо немає — читаємо дані з БД
      SELECT SINGLE FROM /dmo/connection
        FIELDS airport_from_id, airport_to_id
        WHERE carrier_id    = @airlineid
          AND connection_id = @connectionnumber
        INTO ( @DATA(lv_from), @DATA(lv_to) ).

      " Створюємо новий об'єкт
      ro_connection = NEW #( airlineid        = airlineid
                             connectionnumber = connectionnumber
                             fromairport      = lv_from
                             toairport        = lv_to ).

      " Зберігаємо в таблицю
      INSERT VALUE #( airlineid        = airlineid
                      connectionnumber = connectionnumber
                      object           = ro_connection ) INTO TABLE connections.
    ELSE.
      " Якщо є — повертаємо існуючий
      ro_connection = <fs_instance>-object.
    ENDIF.
  ENDMETHOD.

  METHOD get_attributes.
    rv_attributes = |{ airlineid } { connectionnumber }: { fromairport } -> { toairport }|.
  ENDMETHOD.

  METHOD get_n_o_connections.
    rv_count = lines( connections ).
  ENDMETHOD.

ENDCLASS.
