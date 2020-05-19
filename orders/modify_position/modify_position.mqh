#property strict


#include "..\order_processor_register.mqh"
#include "request_modify_position.mqh"
#include "..\..\logger.mqh"

#ifdef __MQL4__
   void ModifyPosition(CRequestModifyPosition* req) {
      
      if (OrderSelect((int)req.order_id,SELECT_BY_TICKET,MODE_TRADES)) {
         if (req.sl < 0) req.sl = req.position_details.GetStoploss();
         if (req.tp < 0) req.tp = req.position_details.GetTakeprofit();
         debug(("Modify order ",req.order_id," price: ",OrderOpenPrice()," sl ",req.sl," tp ",req.tp," ask:",req.symbol.Ask()," bid:",req.symbol.Bid()));
         req.success = OrderModify((int)req.order_id,OrderOpenPrice(),req.sl,req.tp,0);
         if (!req.success) {
            req.error = GetLastError();
         }
      } else {
         req.success = false;
         req.error = GetLastError();
      }
   }
#endif
#ifdef __MQL5__
   void ModifyPosition(CRequestModifyPosition* req) {
      
   }
#endif

void OrderProcessorModifyPosition(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_MODIFY_POSITION) {
      CRequestModifyPosition* req = parameters;
      ModifyPosition(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}

