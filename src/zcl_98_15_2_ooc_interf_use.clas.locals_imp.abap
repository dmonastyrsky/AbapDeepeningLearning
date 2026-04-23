
INTERFACE lif_partner.
  TYPES: BEGIN OF ts_attribute,
           name  TYPE string,
           value TYPE string,
         END OF ts_attribute,
         tt_attributes TYPE STANDARD TABLE OF ts_attribute WITH EMPTY KEY.

  METHODS get_partner_attributes RETURNING VALUE(rt_attributes) TYPE tt_attributes.
ENDINTERFACE.


CLASS lcl_travel_Agency DEFINITION.
  PUBLIC SECTION.
    METHODS add_partner IMPORTING io_partner TYPE REF TO lif_partner.
    "METHODS get_partners RETURNING VALUE(rt_partners) TYPE lif_partner=>tt_attributes.

    DATA mt_partners TYPE TABLE OF REF TO lif_partner.
    METHODS get_partners_refs RETURNING VALUE(rt_partners) LIKE mt_partners.

ENDCLASS.

CLASS lcl_travel_agency IMPLEMENTATION.
  METHOD add_partner.
    APPEND io_partner TO mt_partners.
  ENDMETHOD.

  METHOD get_partners_refs.
    rt_partners = mt_partners.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_airline DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_partner.
    METHODS constructor IMPORTING iv_name TYPE string iv_contact_person TYPE string iv_city TYPE string.
  PRIVATE SECTION.
    DATA: mv_name TYPE string, mv_contact TYPE string, mv_city TYPE string.
ENDCLASS.


CLASS lcl_car_rental DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_partner.
    METHODS constructor IMPORTING iv_name TYPE string iv_contact_person TYPE string iv_has_hgv TYPE abap_bool.
  PRIVATE SECTION.
    DATA: mv_name TYPE string, mv_contact TYPE string, mv_has_hgv TYPE abap_bool.
ENDCLASS.


CLASS lcl_airline IMPLEMENTATION.
  METHOD constructor.
    me->mv_name = iv_name. me->mv_contact = iv_contact_person. me->mv_city = iv_city.
  ENDMETHOD.

  METHOD lif_partner~get_partner_attributes.
    rt_attributes = VALUE #( ( name = 'Name'    value = mv_name )
                             ( name = 'Contact' value = mv_contact )
                             ( name = 'City'    value = mv_city ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_car_rental IMPLEMENTATION.
  METHOD constructor.
    me->mv_name = iv_name. me->mv_contact = iv_contact_person. me->mv_has_hgv = iv_has_hgv.
  ENDMETHOD.

  METHOD lif_partner~get_partner_attributes.
    rt_attributes = VALUE #( ( name = 'Name'    value = mv_name )
                             ( name = 'Contact' value = mv_contact )
                             ( name = 'HGV'     value = COND #( WHEN mv_has_hgv = abap_true THEN 'Yes' ELSE 'No' ) ) ).
  ENDMETHOD.
ENDCLASS.
