#property strict

#include "../order_processor_register.mqh"
#include "request_get_triggered_pending_order.mqh"
#include "../share/order_filters.mqh"

#ifdef __MQL4__

   void GetTriggeredPendingOrder(CRequestGetTriggeredPendingOrder* req) {
      if (OrderSelect((int)req.order_id,SELECT_BY_TICKET,MODE_TRADES) && FilterOrder(OrderType(),ORDER_FILTER_MARKET)) {
         req.success = true;
         req.position_id = req.order_id;
      } else {
         req.success = false;
      }
   }

#endif

void OrderProcessorGetTriggeredPendingOrder(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_GET_TRIGGERED_PENDING_ORDER) {
      CRequestGetTriggeredPendingOrder* req = parameters;
      GetTriggeredPendingOrder(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}