//+------------------------------------------------------------------+
//|                                    processor_moneymanagement.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_request_base.mqh"

class CMoneyManagement {
public:
   virtual double Calculate(CRequest* request) {
      return 0;
   }
};
