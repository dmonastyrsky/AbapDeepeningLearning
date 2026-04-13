CLASS zcl_98_04_2_description_funct DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_98_04_2_description_funct IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    DATA result TYPE i.

    DATA text    TYPE string VALUE `  ABAP  `.
    DATA substring TYPE string VALUE `AB`.
    DATA offset    TYPE i      VALUE 1.

* Call different description functions
******************************************************************************
*    result = strlen(     text ).
*    result = numofchar(  text ).

    result = count(             val = text sub = substring off = offset ).
*    result = find(             val = text sub = substring off = offset ).

*    result = count_any_of(     val = text sub = substring off = offset ).
*    result = find_any_of(      val = text sub = substring off = offset ).

*    result = count_any_not_of( val = text sub = substring off = offset ).
*    result = find_any_not_of(  val = text sub = substring off = offset ).

    out->write( |Text      = `{ text }`| ).
    out->write( |Substring = `{ substring }` | ).
    out->write( |Offset    = { offset } | ).
    out->write( |Result    = { result } | ).

    " strlen: рахує абсолютно всі символи (2 пробіли + 4 літери + 2 пробіли)
    out->write( |strlen( text ) = { strlen( text ) } (Повна довжина рядка)| ).

    " numofchar: ігнорує лише пробіли в кінці (2 пробіли + 4 літери)
    out->write( |numofchar( text ) = { numofchar( text ) } (Довжина без кінцевих пробілів)| ).

    " count_any_of: рахує скільки разів літери 'A' або 'B' зустрічаються після 1-ї позиції (позиції 2, 3, 4)
    out->write( |count_any_of(...) = { count_any_of( val = text sub = substring off = offset ) } (Кількість символів 'A' або 'B' після зміщення)| ).

    " find_any_of: знаходить першу літеру 'A' або 'B' після 1-ї позиції (це 'A' на індексі 2)
    out->write( |find_any_of(...) = { find_any_of( val = text sub = substring off = offset ) } (Індекс першої знайденої літери 'A' або 'B')| ).

    " count_any_not_of: рахує все, що НЕ 'A' і НЕ 'B' після зміщення (пробіл на інд. 1, 'P' на 5, пробіли на 6, 7)
    out->write( |count_any_not_of(...) = { count_any_not_of( val = text sub = substring off = offset ) } (Кількість символів, що не входять у набір 'AB')| ).

    " find_any_not_of: перший символ після зміщення, який не є 'A' або 'B' (це пробіл на індексі 1)
    out->write( |find_any_not_of(...) = { find_any_not_of( val = text sub = substring off = offset ) } (Індекс першого символу не з набору 'AB')| ).


  ENDMETHOD.
ENDCLASS.
