#property strict

#include "../order_request_base.mqh"
#include "../order_request_codes.mqh"

class CRequestGetTriggeredPendingOrder : public CRequest {

public:
   long order_id;
   bool success;
   long position_id;
   virtual int Type() { return ORDER_REQUEST_GET_ORDER_DETAILS; }
   
   CRequestGetTriggeredPendingOrder():
      order_id(-1),
      success(false),
      position_id(-1)
   {}

};
