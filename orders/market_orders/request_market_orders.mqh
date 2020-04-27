#property strict

#include "..\share\request_order.mqh"

class CRequestOpenMarket : public CRequestOrder {
public:
   virtual int Type() { return ORDER_REQUEST_OPEN_MARKET; }
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   CRequestOpenMarket():
      slippage(0),
      comment(NULL),
      magic(0),
      ticket(-1),
      error(0)
   {}
};
