#property strict

#include "..\order_processor_register.mqh"
#include "..\share\orderselect_shared_filters.mqh"
#include "request_select_orders.mqh"

#ifdef __MQL4__

#include "..\share\mt4\pending_order_details_impl.mqh"

   void SelectOrders(CRequestSelectOrders* req) {
      int total = OrdersTotal();
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                  && (!req.filter_by_magic || __FilterByMagicNumber(OrderMagicNumber(),req.magic))
                  && FilterOrder(OrderType(),ORDER_FILTER_PENDING & req.filter))
            {
               CPendingOrderDetailsImpl details;
               req.callback(GetPointer(details),req.callback_obj);
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void SelectOrders(CRequestSelectOrders* req) {
      
   }
#endif

void OrderProcessorSelectOrders(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_SELECT_ORDERS) {
      CRequestSelectOrders* req = parameters;
      SelectOrders(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}