//+------------------------------------------------------------------+
//|                                        request_cancel_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_request_codes.mqh"
#include "order_request_base.mqh"
#include "symbols.mqh"

typedef void (*CancelCallBack)(int order_ticket, bool success, int error);

class CRequestCancelAll : public CRequest {

public:
   CSymbol* symbol;
   int filter;
   int slippage;
   int magic;
   int cnt_closed;
   int cnt_error;
   CancelCallBack callback;

   virtual int Type() { return ORDER_REQUEST_CANCEL_ALL; }
   
   CRequestCancelAll():
      symbol(NULL),
      filter(0),
      slippage(0),
      magic(-1),
      cnt_closed(0),
      cnt_error(0),
      callback(NULL)
   {}

};
