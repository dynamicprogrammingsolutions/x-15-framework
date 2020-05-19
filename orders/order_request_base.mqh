//+------------------------------------------------------------------+
//|                                           order_request_base.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "..\objecttools.mqh"

class CRequest {
   CLASSNAME
public:
   virtual CFaces* GetFaces() {
      ABSTRACT_METHOD_WARNING
      return NULL;
   }
   virtual int Type() {
      return 0;
   }
};

