#property strict

#include "..\order_processor_register.mqh"
#include "..\share\orderselect_shared_filters.mqh"
#include "request_cnt_orders.mqh"

#ifdef __MQL4__
   void CntOrders(CRequestCntOrders* req) {
      int total = OrdersTotal();
      req.cnt = 0;
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if (__FilterBySymbol(OrderSymbol(),req.symbol)
                  && __FilterByMagicNumber(OrderMagicNumber(),req.magic)
                  && FilterOrder(OrderType(),req.filter))
            {
               req.cnt++;
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void CntOrders(CRequestCntOrders* req) {
      
   }
#endif

void OrderProcessorCntOrders(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CNT_ORDERS) {
      CRequestCntOrders* req = parameters;
      CntOrders(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}