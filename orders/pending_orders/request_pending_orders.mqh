#property strict

#include "../share/request_order.mqh"
#include "../share/face_request_error.mqh"

class CRequestOpenPending : public CRequestOrder {
public:
   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestOpenPending>());
      }
      return GetPointer(__faces);
   }

   virtual int Type() { return ORDER_REQUEST_OPEN_PENDING; }
   datetime expiration;
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   bool success;
   
   CRequestOpenPending():
     expiration(0),
     slippage(0),
     comment(NULL),
     magic(0),
     ticket(-1),
     error(0),
     success(false)
   {}
   
};
