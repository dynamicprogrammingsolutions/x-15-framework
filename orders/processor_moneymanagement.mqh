//+------------------------------------------------------------------+
//|                                    processor_moneymanagement.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "request_market_orders.mqh"
#include "request_pending_orders.mqh"

void OrderProcessorMoneyManagement(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET || request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(parameters);
      if (req != NULL) {
         if (CheckPointer(req.mm) != POINTER_INVALID) {
            if (req.symbol == NULL) req.symbol = GetDefaultSymbol();
            req.volume = req.symbol.LotRound(req.mm.Calculate(req));
         }
      }
      next.ProcessOrder(request,parameters);
   } else {
      next.ProcessOrder(request,parameters);
   }
}
