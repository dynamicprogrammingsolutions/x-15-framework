//+------------------------------------------------------------------+
//|                                                     mm_fixed.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "moneymanagement.mqh"

class CMMFixed : public CMoneyManagement {
protected:
   double m_lots;
public:
   CMMFixed(double lots) : m_lots(lots) {}
   virtual double Calculate(CRequest* request) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(request);
      if (req != NULL) {
         return m_lots;
      } else {
         return 0;
      }
   }
};