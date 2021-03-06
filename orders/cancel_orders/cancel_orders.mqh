#property strict

#include "../../logger.mqh"
#include "../order_processor_register.mqh"
#include "request_cancel_orders.mqh"
#include "../share/orderselect_shared_filters.mqh"

#ifdef __MQL4__
   #include "..\share\mt4\pending_order_details_impl.mqh"
   void CancelAll(CRequestCancelAll* req) {
      int total = OrdersTotal();
      req.cnt_closed = 0;
      req.cnt_error = 0;
      CPendingOrderDetailsImpl details;
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                  && __FilterByMagicNumber(OrderMagicNumber(),req.magic)
                  && FilterOrder(OrderType(),ORDER_FILTER_PENDING)
                  && FilterOrder(OrderType(),req.filter)
                  && (req.filter_callback == NULL || req.filter_callback(GetPointer(details))))
            {
               int ticket = OrderTicket();
               print(("Cancel order, parameters: ticket: ",ticket," ask:",Ask," bid: ",Bid));
               bool success = OrderDelete(ticket,clrGray);
               int error = -1;
               if (!success) {
                  error = GetLastError();
                  req.cnt_error++;
               } else {
                  req.cnt_closed++;
               }
               if (req.callback != NULL) {
                  req.callback(OrderTicket(),success,error);
               }
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void CancelAll(CRequestCancelAll* req) {
      
   }
#endif

void OrderProcessorCancelAll(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CANCEL_ALL) {
      CRequestCancelAll* req = parameters;
      CancelAll(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}