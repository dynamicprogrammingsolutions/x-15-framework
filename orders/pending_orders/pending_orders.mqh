#property strict

#include "..\order_processor_register.mqh"
#include "request_pending_orders.mqh"
#include "..\..\logger.mqh"

#ifdef __MQL4__
   
   bool _order_by_market = false;
   
   void OpenPending(CRequestOpenPending* req) {
      debug(("Sending order symbol ",req.symbol.symbol," order type ",req.order_type," volume ",req.volume," price ",req.price," slippage ",req.slippage," sl ",req.sl," tp ",req.tp," comment ",req.comment," magic ",req.magic," expiration ",req.expiration));
      double sl = 0;
      double tp = 0;
      if (!_order_by_market) {
         sl = req.sl;
         tp = req.tp;
      }
      req.success = false;
      int ret = OrderSend(req.symbol.symbol,req.order_type,req.volume,req.price,req.slippage,sl,tp,req.comment,req.magic,req.expiration);
      if (_order_by_market && ret >= 0 && (req.sl != 0 || req.tp != 0)) {
         ret = OrderModify(ret,req.price,req.sl,req.tp,req.expiration);
      }
      if (ret <= 0) {
         req.error = GetLastError();
      } else {
         req.ticket = ret;
         req.success = true;
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

