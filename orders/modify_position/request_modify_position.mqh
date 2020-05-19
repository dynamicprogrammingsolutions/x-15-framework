#property strict


#include "..\order_request_base.mqh"
#include "..\order_request_codes.mqh"
#include "..\symbols.mqh"
#include "..\share\position_details.mqh"
#include "..\share\face_request_error.mqh"

class CRequestModifyPosition : public CRequest {
public:
   virtual CFaces* GetFaces() {
      static CFaces __faces;
      if (!__faces.IsInitialized()) {
         __faces.AddFace(new CFaceRequestErrorT<CRequestModifyPosition>());
      }
      return GetPointer(__faces);
   }


   virtual int Type() { return ORDER_REQUEST_MODIFY_POSITION; }
   CSymbol* symbol;
   long order_id;
   CPositionDetails* position_details;
   double current_price;
   double sl;
   double tp;
   bool success;
   int error;
   
   CRequestModifyPosition():
      order_id(-1),
      sl(-1),
      tp(-1),
      error(0)
   {}
   
};
