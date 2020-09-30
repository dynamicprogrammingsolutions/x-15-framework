#property strict

#include "../order_processor_register.mqh"
#include "../share/request_order.mqh"
#include "../modify_pending_order/request_modify_pending_order.mqh"
#include "../get_order_details/get_order_details.mqh"
#include "../symbols.mqh"

void OrderProcessorPriceRound(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET || request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(parameters);
      if (req != NULL && CheckPointer(req.symbol) != POINTER_INVALID) {
         if (CheckPointer(req.symbol) == POINTER_INVALID) req.symbol = GetDefaultSymbol();
         req.price = req.symbol.PriceRound(req.price);
         req.sl = req.symbol.PriceRound(req.sl);
         req.tp = req.symbol.PriceRound(req.tp);
      } 
   } else if (request == ORDER_REQUEST_MODIFY_PENDING) {
      CRequestModifyPending* req = dynamic_cast<CRequestModifyPending*>(parameters);
      if (req != NULL && CheckPointer(req.symbol) != POINTER_INVALID) {
         req.price = req.symbol.PriceRound(req.price);
         req.sl = req.symbol.PriceRound(req.sl);
         req.tp = req.symbol.PriceRound(req.tp);
      }
   }
   next.ProcessOrder(request,parameters);
}