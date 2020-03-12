//+------------------------------------------------------------------+
//|                                                   cnt_orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "orders.mqh"
#include "order_request_base.mqh"
#include "order_request_codes.mqh"
#include "order_filters.mqh"

class CRequestCntOrders : public CRequest {

public:
   string symbol;
   int filter;
   int slippage;
   int magic;
   int cnt;

   virtual int Type() { return ORDER_REQUEST_CNT_ORDERS; }
   
   CRequestCntOrders():
      symbol(NULL),
      filter(0),
      slippage(0),
      magic(-1),
      cnt(0)
   {}

};

bool __CntOrders_FilterBySymbol(const string symbol, const string filter_symbol) {
   if (filter_symbol == NULL || filter_symbol == "") {
      return symbol == Symbol();
   } else {
      return symbol == filter_symbol;
   }
}

bool __CntOrders_MagicNumber(int magic, int filter_magic) {
   if (filter_magic < 0) return true;
   else return magic == filter_magic;
}

#ifdef __MQL4__
   void CntOrders(CRequestCntOrders* req) {
      int total = OrdersTotal();
      req.cnt = 0;
      for (int i = total-1; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if (__CntOrders_FilterBySymbol(OrderSymbol(),req.symbol)
                  && __CntOrders_MagicNumber(OrderMagicNumber(),req.magic)
                  && FilterOrder(OrderType(),req.filter))
            {
               req.cnt++;
            }
         }
      }
   }
#endif
#ifdef __MQL5__
   void CntOrders(CRequestCntOrders* req) {
      
   }
#endif

void OrderProcessorCntOrders(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_CNT_ORDERS) {
      CRequestCntOrders* req = parameters;
      CntOrders(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}