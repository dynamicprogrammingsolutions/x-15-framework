#property strict

#include "..\..\logger.mqh"
#include "..\order_processor_register.mqh"
#include "request_cancel_order.mqh"

#ifdef __MQL4__
   void CancelOrder(CRequestCancelOrder* req) {
      if (OrderSelect((int)req.order_id,SELECT_BY_TICKET,MODE_TRADES)) {
         int ticket = (int)req.order_id;
         print(("Cancel order, parameters: ticket: ",ticket," ask:",Ask," bid: ",Bid));
         req.success = OrderDelete(ticket,clrGray);
         if (!req.success) {
            req.error = GetLastError();
         }
      }
   }
#endif
#ifdef __MQL5__
   void CancelOrder(CRequestCancelOrder* req) {
      
   }
#endif

void OrderProcessorCancelOrder(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CANCEL_ORDER) {
      CRequestCancelOrder* req = parameters;
      CancelOrder(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}