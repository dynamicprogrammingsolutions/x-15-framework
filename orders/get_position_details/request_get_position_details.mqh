#property strict

#include "..\order_request_base.mqh"
#include "..\order_request_codes.mqh"
#include "..\share\position_details.mqh"

class CRequestGetPositionDetails : public CRequest {

public:
   long position_id;
   bool success;
   CPositionDetails* details;
   int error;

   virtual int Type() { return ORDER_REQUEST_GET_ORDER_DETAILS; }
   
   CRequestGetPositionDetails():
      position_id(-1),
      success(false),
      details(NULL),
      error(-1)
   {}

};
