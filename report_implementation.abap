CLASS lcl_main_report IMPLEMENTATION.

  METHOD init.

    data_select( ).
    call_fb01( ).

  ENDMETHOD.

  METHOD data_select.

    "Seleção de exemplo
    SELECT *
      FROM bseg
      INTO TABLE mt_saida.

  ENDMETHOD.

  METHOD call_fb01.
    "Tabelas
    DATA: lt_accountgl         TYPE TABLE OF bapiacgl09,
          lt_accountreceivable TYPE TABLE OF bapiacar09,
          lt_currencyamount    TYPE TABLE OF bapiaccr09,
          lt_return            TYPE TABLE OF bapiret2.

    "Estruturas
    DATA: ls_header TYPE bapiache09.

    "Variáveis
    DATA: lv_obj_type TYPE bapiache09-obj_type,
          lv_obj_key  TYPE bapiache09-obj_key,
          lv_obj_sys  TYPE bapiache09-obj_sys,
          lv_belnr    TYPE bsid-belnr,
          lv_bukrs    TYPE bsid-bukrs,
          lv_gjahr    TYPE bsid-gjahr.

    "Monta cabeçalho do documento
    mount_header(
      CHANGING
        cs_header = ls_header
    ).

    "Monta itens do documento
    mount_item(
      CHANGING
        ct_accountgl         = lt_accountgl
        ct_accountreceivable = lt_accountreceivable
        ct_currencyamount    = lt_currencyamount
    ).

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = ls_header
      IMPORTING
        obj_type          = lv_obj_type
        obj_key           = lv_obj_key
        obj_sys           = lv_obj_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountreceivable
        currencyamount    = lt_currencyamount
        return            = lt_return.

    IF line_exists( lt_return[ type   = 'S'
                               id     = 'SW'
                               number = '605' ] ).

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      lv_belnr = lv_obj_key+00(10).
      lv_bukrs = lv_obj_key+10(04).
      lv_gjahr = lv_obj_key+14(04).

    ENDIF.

  ENDMETHOD.

  METHOD mount_header.

    cs_header-doc_date   = sy-datum.
    cs_header-doc_type   = 'DZ'.
    cs_header-comp_code  = '1000'.
    cs_header-pstng_date = sy-datum.
    cs_header-username   = sy-uname.
    cs_header-ref_doc_no = 'Texto referente ao campo XBLNR'.
    cs_header-header_txt = 'Texto do cabeçalho do documento'.

  ENDMETHOD.

  METHOD mount_item.

    READ TABLE mt_saida ASSIGNING FIELD-SYMBOL(<fs_saida>) INDEX 1.

    APPEND INITIAL LINE TO ct_accountgl ASSIGNING FIELD-SYMBOL(<fs_accountgl>).
    <fs_accountgl>-itemno_acc = 1.
    <fs_accountgl>-gl_account = <fs_saida>-saknr. "Conta do razão
    <fs_accountgl>-item_text  = 'Texto do item'.
    <fs_accountgl>-pstng_date = sy-datum.
    <fs_accountgl>-comp_code  = '1000'.
    <fs_accountgl>-profit_ctr = '01F000'.

    APPEND INITIAL LINE TO ct_currencyamount ASSIGNING FIELD-SYMBOL(<fs_currencyamount>).
    <fs_currencyamount>-itemno_acc = 1.
    <fs_currencyamount>-currency   = 'BRL'.
    <fs_currencyamount>-amt_doccur = <fs_saida>-dmbtr.

    APPEND INITIAL LINE TO ct_accountreceivable ASSIGNING FIELD-SYMBOL(<fs_accountreceivable>).
    <fs_accountreceivable>-itemno_acc = 2.
    <fs_accountreceivable>-customer   = <fs_saida>-kunnr. "Conta do cliente
    <fs_accountreceivable>-item_text  = 'Texto do item'.
    <fs_accountreceivable>-comp_code  = '1000'.
    <fs_accountreceivable>-sp_gl_ind  = 'A'.
    <fs_accountreceivable>-profit_ctr = '01F000'.

    UNASSIGN <fs_currencyamount>.
    APPEND INITIAL LINE TO ct_currencyamount ASSIGNING <fs_currencyamount>.
    <fs_currencyamount>-itemno_acc = 2.
    <fs_currencyamount>-currency   = 'BRL'.
    <fs_currencyamount>-amt_doccur = <fs_saida>-dmbtr * -1.

  ENDMETHOD.

ENDCLASS.
