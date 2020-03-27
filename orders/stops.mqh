//+------------------------------------------------------------------+
//|                                                        stops.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_processor_register.mqh"
#include "request_market_orders.mqh"
#include "request_pending_orders.mqh"

enum ENUM_STOP_MODE {
   STOP_MODE_SL,
   STOP_MODE_TP,
   STOP_MODE_ENTRY
};

class CStop {
public:
   virtual double Calculate(CRequest* request, ENUM_STOP_MODE stopmode) {
      return 0;
   }
};

double AddToStop(ENUM_STOP_MODE stopmode, ENUM_ORDER_TYPE order_type, double price, double diff) {
   switch (stopmode) {
      case STOP_MODE_SL:
         return AddToLoss(order_type,price,diff);
      case STOP_MODE_TP:
         return AddToProfit(order_type,price,diff);
      case STOP_MODE_ENTRY:
         switch(order_type) {
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_SELL_STOP:
               return AddToProfit(order_type,price,diff);
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_SELL_LIMIT:
               return AddToLoss(order_type,price,diff);
         }
   }
   return 0;
}

class CRequestOpenMarketWithStops : public CRequestOpenMarket {
public:
   CStop* slcalc;
   CStop* tpcalc;
};

class CRequestOpenPendingWithStops : public CRequestOpenPending {
public:
   CStop* slcalc;
   CStop* tpcalc;
   CStop* entrycalc;
};

void OrderProcessorStops(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET) {
      CRequestOpenMarketWithStops* req = dynamic_cast<CRequestOpenMarketWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,req.order_type);
         req.price = req.current_price;
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            req.sl = req.slcalc.Calculate(req,STOP_MODE_SL);
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            req.tp = req.tpcalc.Calculate(req,STOP_MODE_TP);
         }
      }
      next.ProcessOrder(request,parameters);
   } else if (request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOpenPendingWithStops* req = dynamic_cast<CRequestOpenPendingWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,req.order_type);
         if (CheckPointer(req.entrycalc) != POINTER_INVALID) {
            req.price = req.slcalc.Calculate(req,STOP_MODE_ENTRY);
         }
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            req.sl = req.slcalc.Calculate(req,STOP_MODE_SL);
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            req.tp = req.tpcalc.Calculate(req,STOP_MODE_TP);
         }
      }
      next.ProcessOrder(request,parameters);
   } else {
      next.ProcessOrder(request,parameters);
   }
}
