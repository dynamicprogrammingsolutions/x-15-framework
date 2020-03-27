//+------------------------------------------------------------------+
//|                                               pending_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "request_pending_orders.mqh"

#ifdef __MQL4__
   void OpenPending(CRequestOpenPending* req) {
      int ret = OrderSend(req.symbol.symbol,req.order_type,req.volume,req.price,req.slippage,req.sl,req.tp,req.comment,req.magic,req.expiration);
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
      }
   }
#endif
#ifdef __MQL5__
   void OpenPending(CRequestOpenPending* req) {
      int ret = OrderSend(req.symbol,req.order_type,req.volume,req.price,req.slippage,req.sl,req.tp,req.comment,req.magic,req.expiration);
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
      }
   }
#endif

void OrderProcessorOpenPending(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOpenPending* req = parameters;
      OpenPending(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}

