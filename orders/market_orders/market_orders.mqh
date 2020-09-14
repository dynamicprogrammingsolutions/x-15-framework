#property strict

#include "..\order_processor_register.mqh"
#include "request_market_orders.mqh"
#include "..\symbols.mqh"

#ifdef __MQL4__
   bool __order_by_market = false;
   void OpenMarket(CRequestOpenMarket* req) {
      int ret = -1;
      req.success = false;
      if (!__order_by_market) {
         debug(("Sending order ",req.symbol," ",req.order_type," magic: ",req.magic))
         ret = OrderSend(req.symbol.symbol,req.order_type,req.volume,GetPrice(req.symbol,req.order_type),req.slippage,req.sl,req.tp,req.comment,req.magic);
         if (ret <= 0) {
            req.error = GetLastError();
         } else {
            req.success = true;
            req.ticket = ret;
         }
      } else {
         debug(("Sending order ",req.symbol," ",req.order_type," magic: ",req.magic))
         ret = OrderSend(req.symbol.symbol,req.order_type,req.volume,GetPrice(req.symbol,req.order_type),req.slippage,0,0,req.comment,req.magic);
         if (ret <= 0) {
            req.error = GetLastError();
         } else {
            req.ticket = ret;
            if (!OrderModify(req.ticket,0,req.sl,req.tp,0)) {
               req.error = GetLastError();
            } else {
               req.success = true;
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void OpenMarket(CRequestOpenMarket* req) {
      int ret = OrderSend(req.symbol.symbol,req.order_type,req.volume,GetPrice(req.symbol,req.order_type),req.slippage,req.sl,req.tp,req.comment,req.magic);
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
      }
   }
#endif

void OrderProcessorOpenMarket(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET) {
      print(("open market"));
      CRequestOpenMarket* req = parameters;
      OpenMarket(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}
