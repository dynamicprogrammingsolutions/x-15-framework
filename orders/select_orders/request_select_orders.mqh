#property strict

#include "..\order_request_base.mqh"
#include "..\order_request_codes.mqh"
#include "..\symbols.mqh"
#include "..\share\pending_order_details.mqh"

typedef void(*SelectPendingOrdersCallbackFunc)(CPendingOrderDetails* details, void* obj);

class CRequestSelectOrders : public CRequest {

public:
   bool filter_by_symbol;
   bool filter_by_magic;
   CSymbol* symbol;
   int filter;
   int magic;
   int cnt;
   SelectPendingOrdersCallbackFunc callback;
   void* callback_obj;

   virtual int Type() { return ORDER_REQUEST_SELECT_ORDERS; }
   
   CRequestSelectOrders():
      filter_by_symbol(true),
      filter_by_magic(true),
      symbol(NULL),
      filter(0),
      magic(-1),
      cnt(0),
      callback(NULL),
      callback_obj(NULL)
   {}

};


