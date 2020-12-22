#property strict

#include "../order_request_codes.mqh"
#include "../order_request_base.mqh"
#include "../symbols.mqh"
#include "../share/face_request_error.mqh"

class CRequestClosePosition : public CRequest {

public:
   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestClosePosition>());
      }
      return GetPointer(__faces);
   }

   long position_id;  
   long new_position_id;
   double close_volume;
   int slippage;
   bool success;
   int error;
   virtual int Type() { return ORDER_REQUEST_CLOSE_POSITION; }
   
   CRequestClosePosition():
      close_volume(0),
      position_id(-1),
      success(false),
      error(-1),
      slippage(0),
      new_position_id(-1)
   {}

};
