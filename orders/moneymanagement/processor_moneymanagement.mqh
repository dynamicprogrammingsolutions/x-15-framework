#property strict

#include "../order_processor_register.mqh"
#include "../share/request_order.mqh"

void OrderProcessorMoneyManagement(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET || request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(parameters);
      if (req != NULL) {
         if (CheckPointer(req.mm) != POINTER_INVALID) {
            req.volume = req.symbol.LotRound(req.mm.Calculate(req));
            print(("calculated volume: ",req.volume));
         }
      }
      next.ProcessOrder(request,parameters);
   } else {
      next.ProcessOrder(request,parameters);
   }
}
