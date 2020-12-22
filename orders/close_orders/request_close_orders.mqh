#property strict

#include "../order_request_codes.mqh"
#include "../order_request_base.mqh"
#include "../symbols.mqh"
#include "../share/position_details.mqh"

typedef void (*CloseCallBack)(int order_ticket, bool success, int error);
typedef bool(*CloseOrdersFilterCallback)(CPositionDetails* details);


class CRequestCloseAll : public CRequest {

public:
   CSymbol* symbol;
   bool filter_by_symbol;
   int filter;
   CloseOrdersFilterCallback filter_callback;
   int slippage;
   int magic;
   int cnt_closed;
   int cnt_error;
   CloseCallBack callback;

   virtual int Type() { return ORDER_REQUEST_CLOSE_ALL; }
   
   CRequestCloseAll():
      filter_by_symbol(true),
      symbol(NULL),
      filter(0),
      slippage(0),
      magic(-1),
      cnt_closed(0),
      cnt_error(0),
      callback(NULL)
   {}

};
