#include "symbols.mqh"
#include "market_orders.mqh"
#include "pending_orders.mqh"

int _magic = 1234;
int _slippage = 30;
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

CIteratorObj<CPendingOrderDetails>* GetOrdersIterator(int filter = ORDER_FILTER_ANY) {
   CRequestSelectOrders req;
   req.filter_by_symbol = true;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   ProcessOrder(ORDER_REQUEST_SELECT_ORDERS,GetPointer(req));
   return req.iterator;
}

bool GetOrderDetails(long id, CPendingOrderDetails*& details) {
   CRequestGetOrderDetails req;
   req.order_id = id;
   ProcessOrder(ORDER_REQUEST_GET_ORDER_DETAILS,GetPointer(req));
   if (req.success) details = req.details;
   return req.success;
}


bool GetPositionDetails(long id, CPositionDetails*& details) {
   CRequestGetPositionDetails req;
   req.position_id = id;
   ProcessOrder(ORDER_REQUEST_GET_POSITION_DETAILS,GetPointer(req));
   if (req.success) details = req.details;
   return req.success;
}

bool GetTriggeredPositionByOrderId(long id, long& posid) {
   CRequestGetTriggeredPendingOrder req;
   req.order_id = id;
   ProcessOrder(ORDER_REQUEST_GET_TRIGGERED_PENDING_ORDER,GetPointer(req));
   if (req.success) posid = req.position_id;
   return req.success;
}

/*bool GetMarketOrder(int id, CPendingOrderDetails* ) {
   
}*/

int OpenMarketOrder(ENUM_ORDER_TYPE type, double volume, double sl, double tp, string comment = NULL) {
   CRequestOpenMarket req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.slippage = _slippage;
   req.volume = volume;
   req.order_type = type;
   req.sl = sl;
   req.tp = tp;
   req.comment = comment;
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket;
}

int OpenPendingOrder(ENUM_ORDER_TYPE type, double volume, double entry, double sl, double tp, string comment = NULL) {
   CRequestOpenPending req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.volume = volume;
   req.order_type = type;
   req.price = entry;
   req.sl = sl;
   req.tp = tp;
   req.comment = comment;
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   _lastsuccess = req.success;
   _lasterror = req.error;
   return req.ticket;
}

int CntOrders(int filter = ORDER_FILTER_ANY) {
   CRequestCntOrders req;
   req.symbol = _symbol;
   req.magic = _magic;
   req.filter = filter;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
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


bool ClosePosition(long posid) {
   CRequestClosePosition req;
   req.position_id = posid;
   ProcessOrder(ORDER_REQUEST_CLOSE_POSITION,GetPointer(req));
   return req.success;
}

bool ClosePosition(long posid, double volume) {
   CRequestClosePosition req;
   req.position_id = posid;
   req.close_volume = volume;
   ProcessOrder(ORDER_REQUEST_CLOSE_POSITION,GetPointer(req));
   return req.success;
}


bool CancelOrder(long orderid) {
   CRequestCancelOrder req;
   req.order_id = orderid;
   ProcessOrder(ORDER_REQUEST_CANCEL_ORDER,GetPointer(req));
   return req.success;
}