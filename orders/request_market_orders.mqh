//+------------------------------------------------------------------+
//|                                        request_market_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_request_codes.mqh"
#include "order_request_base.mqh"

class CRequestOpenMarket : public CRequest {
public:
   virtual int Type() { return ORDER_REQUEST_OPEN_MARKET; }
   string symbol;
   ENUM_ORDER_TYPE order_type;
   double volume;
   double sl;
   double tp;
   int slippage;
   string comment;
   int magic;
   int ticket;
   int error;
   CRequestOpenMarket():
      symbol(NULL),
      order_type(-1),
      volume(0),
      sl(0),
      tp(0),
      slippage(0),
      comment(NULL),
      magic(0),
      ticket(-1),
      error(0)
   {}
};
