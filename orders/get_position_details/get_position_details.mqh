#property strict

#include "../order_processor_register.mqh"
#include "request_get_position_details.mqh"
#include "../share/order_filters.mqh"

#ifdef __MQL4__

#include "..\share\mt4\position_details_impl.mqh"
   
   CPositionDetailsImpl __GetPositionDetails_PositionDetailsImpl;
   
   void GetPositionDetails(CRequestGetPositionDetails* req) {
      if (OrderSelect((int)req.position_id,SELECT_BY_TICKET,MODE_TRADES)) {
         if (FilterOrder(OrderType(),ORDER_FILTER_MARKET) && OrderCloseTime() == 0) {
            req.success = true;
            req.details = GetPointer(__GetPositionDetails_PositionDetailsImpl);
         } else {
            if (req.include_closed && FilterOrder(OrderType(),ORDER_FILTER_MARKET)) {
               req.success = true;
               req.details = GetPointer(__GetPositionDetails_PositionDetailsImpl);
            } else {
               //Print("unsuccessful selecting order, include closed: ",req.include_closed,", order type: ",EnumToString((ENUM_ORDER_TYPE)OrderType())," close time: ",OrderCloseTime());
               req.success = false;
               req.error = 0;
            }
         } 
      } else {
         /*if (req.include_closed) {
            if (OrderSelect((int)req.position_id,SELECT_BY_TICKET,MODE_HISTORY)) {
               if (FilterOrder(OrderType(),ORDER_FILTER_MARKET)) {
                  req.success = true;
                  req.details = GetPointer(__GetPositionDetails_PositionDetailsImpl);
               } else {
                  req.success = false;
                  req.error = 0;
               }
            } else {
               req.success = false;
               req.error = GetLastError();
            }
         } else {*/
            req.success = false;
            req.error = GetLastError();
         /*}*/
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