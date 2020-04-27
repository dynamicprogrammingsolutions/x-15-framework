#property strict

#include "..\share\request_order.mqh"

class CRequestOpenPending : public CRequestOrder {
public:
   virtual int Type() { return ORDER_REQUEST_OPEN_PENDING; }
   datetime expiration;
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   
   CRequestOpenPending():
     expiration(0),
     slippage(0),
     comment(NULL),
     magic(0),
     ticket(-1),
     error(0)
   {}
   
};
