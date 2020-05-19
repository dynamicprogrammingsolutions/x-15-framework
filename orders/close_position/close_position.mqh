#property strict

#include "..\..\logger.mqh"
#include "..\order_processor_register.mqh"
#include "request_close_position.mqh"

#ifdef __MQL4__
   void ClosePosition(CRequestClosePosition* req) {
      if (OrderSelect((int)req.position_id,SELECT_BY_TICKET,MODE_TRADES)) {
         int ticket = (int)req.position_id;
         double lots = OrderLots();
         CSymbolImpl __sym(OrderSymbol());
         double price = GetClosePrice(GetPointer(__sym),(ENUM_ORDER_TYPE)OrderType());
         print(("Close position, parameters: tcket: ",ticket," lots: ",lots," price: ",price," slippage: ",req.slippage," ask:",Ask," bid: ",Bid));
         req.success = OrderClose(ticket,lots,price,req.slippage,clrGray);
         if (! req.success) {
            req.error = GetLastError();
         }
      }
   }
#endif
#ifdef __MQL5__
   void ClosePosition(CRequestClosePosition* req) {
      
   }
#endif

void OrderProcessorClosePosition(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CLOSE_POSITION) {
      CRequestClosePosition* req = parameters;
      ClosePosition(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}