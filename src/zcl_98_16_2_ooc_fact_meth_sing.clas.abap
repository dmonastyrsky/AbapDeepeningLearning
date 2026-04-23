CLASS zcl_98_16_2_ooc_fact_meth_sing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_16_2_ooc_fact_meth_sing IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA connection TYPE REF TO lcl_connection.
    DATA t_connections TYPE TABLE OF REF TO lcl_connection.
    DATA count TYPE i.

    " Debug the method to show that the class returns objects, but that there are different
    " objects for the same combination of airline and flight number

    connection = lcl_connection=>get_connection( airlineid        = 'LH'
                                                 connectionnumber = '0400' ).

    APPEND connection TO t_connections.

    connection = lcl_connection=>get_connection( airlineid        = 'LH'
                                                 connectionnumber = '0401' ).
    APPEND connection TO t_connections.

    LOOP AT t_connections INTO connection.

      out->write(  connection->get_attributes( ) ).

    ENDLOOP.

    out->write(  |Es wurden dennoch| && | | && lcl_connection=>get_n_o_connections( ) && | | && |Instanzen erstellt| ).


  ENDMETHOD.
ENDCLASS.
