#property strict

#include "../order_request_base.mqh"
#include "../order_request_codes.mqh"
#include "../symbols.mqh"
#include "../share/pending_order_details.mqh"
#include "../share/face_request_error.mqh"

class CRequestModifyPending : public CRequest {
public:

   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestModifyPending>());
      }
      return GetPointer(__faces);
   }

   virtual int Type() { return ORDER_REQUEST_MODIFY_PENDING; }
   CSymbol* symbol;
   long order_id;
   CPendingOrderDetails* order_details;
   double current_price;
   double price;
   double sl;
   double tp;
   datetime expiration;
   string comment;
   bool success;
   int error;
   
   CRequestModifyPending():
      order_id(-1),
      price(0),
      sl(-1),
      tp(-1),
      expiration(-1),
      error(0)
   {}
   
};
