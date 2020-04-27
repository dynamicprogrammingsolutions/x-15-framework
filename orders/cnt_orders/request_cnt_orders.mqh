#property strict

#include "..\order_request_base.mqh"
#include "..\order_request_codes.mqh"
#include "..\symbols.mqh"

class CRequestCntOrders : public CRequest {

public:
   CSymbol* symbol;
   int filter;
   int slippage;
   int magic;
   int cnt;

   virtual int Type() { return ORDER_REQUEST_CNT_ORDERS; }
   
   CRequestCntOrders():
      symbol(NULL),
      filter(0),
      slippage(0),
      magic(-1),
      cnt(0)
   {}

};
