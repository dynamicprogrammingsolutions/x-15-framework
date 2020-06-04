#property strict

#include "..\order_processor_register.mqh"
#include "request_get_position_details.mqh"
#include "..\share\order_filters.mqh"

#ifdef __MQL4__

#include "..\share\mt4\position_details_impl.mqh"
   
   void GetPositionDetails(CRequestGetPositionDetails* req) {
      static CPositionDetailsImpl details;
      if (OrderSelect((int)req.position_id,SELECT_BY_TICKET,MODE_TRADES)) {
         if (FilterOrder(OrderType(),ORDER_FILTER_MARKET) && OrderCloseTime() == 0) {
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

void OrderProcessorGetPositionDetails(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_GET_POSITION_DETAILS) {
      CRequestGetPositionDetails* req = parameters;
      GetPositionDetails(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}