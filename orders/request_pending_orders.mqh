//+------------------------------------------------------------------+
//|                                       request_pending_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "request_order.mqh"

class CRequestOpenPending : public CRequestOrder {
public:
   virtual int Type() { return ORDER_REQUEST_OPEN_PENDING; }
   datetime expiration;
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   
   CRequestOpenPending():
     expiration(0),
     slippage(0),
     comment(NULL),
     magic(0),
     ticket(-1),
     error(0)
   {}
   
};
