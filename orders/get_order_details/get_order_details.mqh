#property strict

#include "../order_processor_register.mqh"
#include "request_get_order_details.mqh"
#include "../share/order_filters.mqh"

#ifdef __MQL4__

#include "..\share\mt4\pending_order_details_impl.mqh"
   
   void GetOrderDetails(CRequestGetOrderDetails* req) {
      // TODO: this is a simple solution for getting the order details, however it contains a vulnerability of getting 
      // invalid data if the CPendingOrderDetails implementation object is used after subsequent requests.
      // a possible solution is to have a singleton object to which the implementation calls will be delegated,
      // and when the singleton detects subsequent calls, it will invalidate the instance.
      // To make better performance, and to avoid "new" keyword for instances, there could be an instance pool
      // this should be tested for performance (compared to using new object instead, and compared to using a simpler solution which doesn't
      // need constructing an object at all.
      static CPendingOrderDetailsImpl details;
      if (OrderSelect((int)req.order_id,SELECT_BY_TICKET,MODE_TRADES) && FilterOrder(OrderType(),ORDER_FILTER_PENDING)) {
         if (OrderCloseTime() == 0) {
            req.success = true;
            req.details = GetPointer(details);
         } else {
            req.success = false;
            req.error = 0;
         }
      } else {
         req.success = false;
         req.error = GetLastError();
      }
   }

#endif

void OrderProcessorGetOrderDetails(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_GET_ORDER_DETAILS) {
      CRequestGetOrderDetails* req = parameters;
      GetOrderDetails(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}