//+------------------------------------------------------------------+
//|                                       request_pending_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_request_codes.mqh"
#include "order_request_base.mqh"

class CRequestOpenPending : public CRequest {
public:
   virtual int Type() { return ORDER_REQUEST_OPEN_PENDING; }
   string symbol;
   ENUM_ORDER_TYPE order_type;
   double volume;
   double price;
   double sl;
   double tp;
   datetime expiration;
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   
   CRequestOpenPending():
     symbol(NULL),
     order_type(-1),
     volume(0),
     price(0),
     sl(0),
     tp(0),
     expiration(0),
     slippage(0),
     comment(NULL),
     magic(0),
     ticket(-1),
     error(0)
   {}
   
};
