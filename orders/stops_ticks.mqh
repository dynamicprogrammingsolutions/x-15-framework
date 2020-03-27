//+------------------------------------------------------------------+
//|                                                  stops_ticks.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "stops.mqh"

#include "request_order.mqh"

class CStopTicks : public CStop {
   int m_ticks;
public:
   CStopTicks(int ticks) : m_ticks(ticks) {}
   virtual double Calculate(CRequest* request, ENUM_STOP_MODE stopmode) {
      if (dynamic_cast<CRequestOrder*>(request) != NULL) {
         CRequestOrder* req_order = request;
         switch(stopmode) {
            case STOP_MODE_SL:
            case STOP_MODE_TP:
               return AddToStop(stopmode,req_order.order_type,req_order.price,m_ticks*req_order.symbol.TickSize());
            case STOP_MODE_ENTRY:
               return AddToStop(stopmode,req_order.order_type,req_order.current_price,m_ticks*req_order.symbol.TickSize());
         }
         
      }
      return 0;
   }
};