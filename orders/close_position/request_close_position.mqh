#property strict

#include "..\order_request_codes.mqh"
#include "..\order_request_base.mqh"
#include "..\symbols.mqh"

class CRequestClosePosition : public CRequest {

public:
   long position_id;
   int slippage;
   bool success;
   int error;
   virtual int Type() { return ORDER_REQUEST_CLOSE_POSITION; }
   
   CRequestClosePosition():
      position_id(-1),
      success(false),
      error(-1),
      slippage(0)
   {}

};
