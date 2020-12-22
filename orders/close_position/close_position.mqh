#property strict

#include "../../logger.mqh"
#include "../order_processor_register.mqh"
#include "request_close_position.mqh"

#ifdef __MQL4__
   void ClosePosition(CRequestClosePosition* req) {
      if (OrderSelect((int)req.position_id,SELECT_BY_TICKET,MODE_TRADES)) {
         int ticket = (int)req.position_id;
         double lots = OrderLots();
         CSymbolImpl __sym(OrderSymbol());
         double price = GetClosePrice(GetPointer(__sym),(ENUM_ORDER_TYPE)OrderType());
         if (req.close_volume < __sym.MinLot()) {
            req.close_volume = lots;
         } else {
            req.close_volume = __sym.LotRound(req.close_volume);
         }
         print(("Close position, parameters: tcket: ",ticket," lots: ",lots," close volume: ",req.close_volume," price: ",price," slippage: ",req.slippage," ask:",Ask," bid: ",Bid));
         req.success = OrderClose(ticket,req.close_volume,price,req.slippage,clrGray);
         if (! req.success) {
            req.error = GetLastError();
         } else {
            if (req.close_volume != 0 && __sym.LotRound(req.close_volume) != __sym.LotRound(lots)) {
               req.new_position_id = __ClosePosition_FindNewTicket(OrderOpenTime(),OrderOpenPrice(),OrderSymbol());
            }
         }
      }
   }
   
   int __ClosePosition_FindNewTicket(datetime orderopentime, double orderopenprice, string ordersymbol)
   {
      for (int i = OrdersTotal()-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if (OrderSymbol() == ordersymbol && OrderOpenTime() == orderopentime && OrderOpenPrice() == orderopenprice) {
               Print("New ticket found afer partial close:",OrderTicket());
               return(OrderTicket());
            }
         }         
      }
      Print("New ticket not found after partial close");
      return(-1);
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