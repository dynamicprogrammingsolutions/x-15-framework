#property strict

#include "../../logger.mqh"
#include "../order_processor_register.mqh"
#include "request_close_orders.mqh"
#include "../share/orderselect_shared_filters.mqh"

#ifdef __MQL4__
   #include "..\share\mt4\position_details_impl.mqh"
   void CloseAll(CRequestCloseAll* req) {
      int total = OrdersTotal();
      req.cnt_closed = 0;
      req.cnt_error = 0;
      CPositionDetailsImpl details;
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                  && __FilterByMagicNumber(OrderMagicNumber(),req.magic)
                  && FilterOrder(OrderType(),ORDER_FILTER_MARKET)
                  && FilterOrder(OrderType(),req.filter)
                  && (req.filter_callback == NULL || req.filter_callback(GetPointer(details))))
            {
               int ticket = OrderTicket();
               double lots = OrderLots();
               double price;
               if (req.symbol != NULL) {
                  price = GetClosePrice(req.symbol,(ENUM_ORDER_TYPE)OrderType());
               } else {
                  price = GetClosePrice(OrderSymbol(),(ENUM_ORDER_TYPE)OrderType());
               }
               print(("Close position, parameters: tcket: ",ticket," lots: ",lots," price: ",price," slippage: ",req.slippage," ask:",Ask," bid: ",Bid));
               bool success = OrderClose(ticket,lots,price,req.slippage,clrGray);
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
   void CloseAll(CRequestCloseAll* req) {
      
   }
#endif

void OrderProcessorCloseOrders(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CLOSE_ALL) {
      CRequestCloseAll* req = parameters;
      CloseAll(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}