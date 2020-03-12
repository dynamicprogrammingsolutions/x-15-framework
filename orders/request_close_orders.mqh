//+------------------------------------------------------------------+
//|                                         request_close_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_request_codes.mqh"
#include "order_request_base.mqh"

typedef void (*CloseCallBack)(int order_ticket, bool success, int error);

class CRequestCloseAll : public CRequest {

public:
   string symbol;
   int filter;
   int slippage;
   int magic;
   int cnt_closed;
   int cnt_error;
   CloseCallBack callback;

   virtual int Type() { return ORDER_REQUEST_CLOSE_ALL; }
   
   CRequestCloseAll():
      symbol(NULL),
      filter(0),
      slippage(0),
      magic(-1),
      cnt_closed(0),
      cnt_error(0),
      callback(NULL)
   {}

};
