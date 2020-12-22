#property strict

#include "../order_request_codes.mqh"
#include "../order_request_base.mqh"
#include "../symbols.mqh"
#include "../share/pending_order_details.mqh"

typedef void (*CancelCallBack)(int order_ticket, bool success, int error);
typedef bool(*CancelOrdersFilterCallback)(CPendingOrderDetails* details);

class CRequestCancelAll : public CRequest {

public:
   CSymbol* symbol;
   bool filter_by_symbol;
   int filter;
   CancelOrdersFilterCallback filter_callback;
   int slippage;
   int magic;
   int cnt_closed;
   int cnt_error;
   CancelCallBack callback;

   virtual int Type() { return ORDER_REQUEST_CANCEL_ALL; }
   
   CRequestCancelAll():
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
