#include "order_helper_basic.mqh"
#include "stops.mqh"
#include "moneymanagement.mqh"

#define ORDER_HELPER_MQH

int OpenMarketOrder(ENUM_ORDER_TYPE type, CMoneyManagement* mm, CStop* slcalc, CStop* tpcalc, string comment = NULL) {
   CRequestOpenMarketWithStops req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.slippage = _slippage;
   req.mm = mm;
   req.order_type = type;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   req.comment = comment;
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket;
}

int OpenPendingOrder(ENUM_ORDER_TYPE type, CMoneyManagement* mm, CStop* entrycalc, CStop* slcalc, CStop* tpcalc, string comment = NULL) {
   CRequestOpenPendingWithStops req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.mm = mm;
   req.order_type = type;
   req.entrycalc = entrycalc;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   req.comment = comment;
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket; 
}

bool ModifyPendingOrder(CPendingOrderDetails* order_details, CStop* entrycalc, CStop* slcalc, CStop* tpcalc) {
   CRequestModifyPendingWithStops req;
   req.symbol = order_details.GetCSymbol();
   req.order_id = order_details.GetId();
   req.order_details = order_details;
   req.entrycalc = entrycalc;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_MODIFY_PENDING,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return _lastsuccess;
}

void TrailingSLByStopcalc(CPositionDetails* pos, CStop* ts_calc) {
   CRequestModifyPositionWithStops req;
   req.order_id = pos.GetId();
   req.position_details = pos;
   req.symbol = pos.GetCSymbol();
   req.slcalc = ts_calc;
   ProcessOrder(ORDER_REQUEST_MODIFY_POSITION,GetPointer(req));
   if (req.error > 1) {
      print(("Couldn't modify SL of order ",req.order_id," Error: ",req.error," ",ErrorDescription(req.error)));
   }
}
