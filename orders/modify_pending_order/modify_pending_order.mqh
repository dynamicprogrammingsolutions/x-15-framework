#property strict

#include "../order_processor_register.mqh"
#include "request_modify_pending_order.mqh"
#include "../../logger.mqh"
#include "../share/order_filters.mqh"

#ifdef __MQL4__

   color _modify_pending_buy = clrBlue;
   color _modify_pending_sell = clrRed;

   void ModifyPending(CRequestModifyPending* req) {
      if (req.price == 0) req.price = req.order_details.GetEntryPrice();
      if (req.sl < 0) req.sl = req.order_details.GetStoploss();
      if (req.tp < 0) req.tp = req.order_details.GetTakeprofit();
      if (req.expiration < 0) req.expiration = req.order_details.GetExpiration();
      debug(("Modify order ",req.order_id," price ",req.price," sl ",req.sl," tp ",req.tp," expiration ",req.expiration));
      req.success = OrderModify((int)req.order_id,req.price,req.sl,req.tp,req.expiration,__ModifyPendingGetColor(req));
      if (!req.success) {
         req.error = GetLastError();
      }
   }
   
   color __ModifyPendingGetColor(CRequestModifyPending* req) {
      if (FilterOrder(req.order_details.GetOrderType(),ORDER_FILTER_LONG)) {
         return _modify_pending_buy;
      } else {
         return _modify_pending_sell;
      }
   }
   
#endif
#ifdef __MQL5__
   void ModifyPending(CRequestModifyPending* req) {
      
   }
#endif

void OrderProcessorModifyPending(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_MODIFY_PENDING) {
      CRequestModifyPending* req = parameters;
      ModifyPending(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}

