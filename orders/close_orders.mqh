//+------------------------------------------------------------------+
//|                                                 close_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "order_filters.mqh"
#include "request_close_orders.mqh"
#include "orderselect_shared_filters.mqh"
#include "symbols.mqh"

#ifdef __MQL4__
   void CloseAll(CRequestCloseAll* req) {
      int total = OrdersTotal();
      req.cnt_closed = 0;
      req.cnt_error = 0;
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if (__FilterBySymbol(OrderSymbol(),req.symbol)
                  && __FilterByMagicNumber(OrderMagicNumber(),req.magic)
                  && FilterOrder(OrderType(),req.filter))
            {
               int ticket = OrderTicket();
               double lots = OrderLots();
               double price = GetClosePrice(req.symbol,(ENUM_ORDER_TYPE)OrderType());
               Print("Close position, parameters: tcket: ",ticket," lots: ",lots," price: ",price," slippage: ",req.slippage," ask:",Ask," bid: ",Bid);
               bool success = OrderClose(ticket,lots,price,req.slippage,clrGray);
               int error = -1;
               if (!success) {
                  error = GetLastError();
                  req.cnt_error++;
               } else {
                  req.cnt_closed++;
               }
               if (req.callback != NULL) {
                  req.callback(OrderTicket(),success,error);
               }
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void CloseAll(CRequestCloseAll* req) {
      
   }
#endif

void OrderProcessorCloseAll(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CLOSE_ALL) {
      CRequestCloseAll* req = parameters;
      CloseAll(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}