#include "symbols.mqh"
#include "market_orders.mqh"
#include "pending_orders.mqh"
#include "stops.mqh"
#include "moneymanagement.mqh"

int _magic = 1234;
CSymbol* _symbol = GetSymbol(NULL);
bool _lastsuccess = true;
int _lasterror = 0;

CIteratorObj<CPositionDetails>* GetPositionsIterator(int filter = ORDER_FILTER_ANY) {
   CRequestSelectPositions req;
   req.filter_by_symbol = true;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   ProcessOrder(ORDER_REQUEST_SELECT_POSITIONS,GetPointer(req));
   return req.iterator;
}

int CntOrders(int filter = ORDER_FILTER_ANY) {
   CRequestCntOrders req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
}

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

void __DefaultCloseCallback(int order_ticket, bool success, int error) {
   if (!success) {
      alert("close error: ",ErrorDescription(error));
   }
}

CloseCallBack _CloseCallback = __DefaultCloseCallback;

void CloseAll(int filter = ORDER_FILTER_ANY) {
   CRequestCloseAll req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   req.callback = _CloseCallback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void CancelAll(int filter = ORDER_FILTER_ANY) {
   CRequestCancelAll req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   req.callback = _CloseCallback;
   ProcessOrder(ORDER_REQUEST_CANCEL_ALL,GetPointer(req));
}