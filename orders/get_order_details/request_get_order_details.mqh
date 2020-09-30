#property strict

#include "../order_request_base.mqh"
#include "../order_request_codes.mqh"
#include "../share/pending_order_details.mqh"

class CRequestGetOrderDetails : public CRequest {

public:
   long order_id;
   bool success;
   CPendingOrderDetails* details;
   int error;

   virtual int Type() { return ORDER_REQUEST_GET_ORDER_DETAILS; }
   
   CRequestGetOrderDetails():
      order_id(-1),
      success(false),
      details(NULL),
      error(-1)
   {}

};
