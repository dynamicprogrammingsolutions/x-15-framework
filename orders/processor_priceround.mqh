//+------------------------------------------------------------------+
//|                                         processor_priceround.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "request_order.mqh"
#include "symbols.mqh"

void OrderProcessorPriceRound(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET || request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(parameters);
      if (req != NULL) {
         if (CheckPointer(req.symbol) == POINTER_INVALID) req.symbol = GetDefaultSymbol();
         req.price = req.symbol.PriceRound(req.price);
         req.sl = req.symbol.PriceRound(req.sl);
         req.tp = req.symbol.PriceRound(req.tp);
      } 
      next.ProcessOrder(request,parameters);
   } else {
      next.ProcessOrder(request,parameters);
   }
}