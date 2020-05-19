#property strict

#include "..\share\request_order.mqh"
#include "..\share\face_request_error.mqh"

class CRequestOpenMarket : public CRequestOrder {
public:

   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestOpenMarket>());
      }
      return GetPointer(__faces);
   }

   virtual int Type() { return ORDER_REQUEST_OPEN_MARKET; }
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   bool success;
   CRequestOpenMarket():
      slippage(0),
      comment(NULL),
      magic(0),
      ticket(-1),
      error(0),
      success(false)
   {}
};
