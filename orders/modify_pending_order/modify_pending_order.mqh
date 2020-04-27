#property strict

#include "..\order_processor_register.mqh"
#include "request_modify_pending_order.mqh"
#include "..\..\logger.mqh"

#ifdef __MQL4__
   void ModifyPending(CRequestModifyPending* req) {
      debug("Modify order ",req.order_id," price ",req.price," sl ",req.sl," tp ",req.tp," expiration ",req.expiration);
      req.success = OrderModify((int)req.order_id,req.price,req.sl,req.tp,req.expiration);
      if (!req.success) {
         req.error = GetLastError();
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

