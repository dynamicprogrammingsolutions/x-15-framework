#property strict

#include "../order_request_codes.mqh"
#include "../order_request_base.mqh"
#include "../symbols.mqh"
#include "../share/face_request_error.mqh"

class CRequestCancelOrder : public CRequest {

public:
   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestCancelOrder>());
      }
      return GetPointer(__faces);
   }

   long order_id;
   bool success;
   int error;
   virtual int Type() { return ORDER_REQUEST_CANCEL_ORDER; }
   
   CRequestCancelOrder():
      order_id(-1),
      success(false),
      error(-1)
   {}

};
