//+------------------------------------------------------------------+
//|                                           face_request_error.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "../../objecttools.mqh"

class CFaceRequestError : public CFace {
CLASSID
protected:
   CFaceRequestError() {}
public:
   virtual bool GetSuccess(void* obj) {
      return false;
   }
   virtual int GetError(void* obj) {
      return 0;
   }
};

template<typename T>
class CFaceRequestErrorT : public CFaceRequestError {
public:
   virtual bool GetSuccess(void* obj) {
      return ((T*)obj).success;
   }
   virtual int GetError(void* obj) {
      return ((T*)obj).error;
   }
};