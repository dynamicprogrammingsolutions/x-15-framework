//+------------------------------------------------------------------+
//|                                                market_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "orders.mqh"
#include "request_market_orders.mqh"
#include "symbols.mqh"

#ifdef __MQL4__

   void OpenMarket(CRequestOpenMarket* req) {
      int ret = OrderSend(req.symbol,req.order_type,req.volume,GetPrice(req.symbol,req.order_type),req.slippage,req.sl,req.tp,req.comment,req.magic);
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
      }
   }
#endif
#ifdef __MQL5__
   void OpenMarket(CRequestOpenMarket* req) {
      int ret = OrderSend(req.symbol,req.order_type,req.volume,GetPrice(req.symbol,req.order_type),req.slippage,req.sl,req.tp,req.comment,req.magic);
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
      }
   }
#endif

void OrderProcessorOpenMarket(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET) {
      CRequestOpenMarket* req = parameters;
      OpenMarket(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}
