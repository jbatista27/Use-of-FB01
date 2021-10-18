CLASS lcl_main_report DEFINITION.

  PUBLIC SECTION.
    METHODS: init.

  PRIVATE SECTION.
    "Tabelas
    DATA: mt_saida TYPE TABLE OF bseg.

    METHODS:
      data_select,
      call_fb01,
      mount_header
        CHANGING cs_header TYPE bapiache09,
      mount_item
        CHANGING
          ct_accountgl         TYPE bapiacgl09_tab
          ct_accountreceivable TYPE bapiacar09_tab
          ct_currencyamount    TYPE bapiaccr09_tab.


ENDCLASS.
