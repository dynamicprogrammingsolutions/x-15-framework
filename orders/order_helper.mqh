#include "order_helper_basic.mqh"
#include "stops.mqh"
#include "moneymanagement.mqh"


int OpenMarketOrder(ENUM_ORDER_TYPE type, CMoneyManagement* mm, CStop* slcalc, CStop* tpcalc) {
   CRequestOpenMarketWithStops req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.mm = mm;
   req.order_type = type;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket;
}

int OpenPendingOrder(ENUM_ORDER_TYPE type, CMoneyManagement* mm, CStop* entrycalc, CStop* slcalc, CStop* tpcalc) {
   CRequestOpenPendingWithStops req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.mm = mm;
   req.order_type = type;
   req.entrycalc = entrycalc;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket; 
}
