#property strict

#include "../order_processor_register.mqh"
#include "request_with_stops.mqh"
#include "stopcalc.mqh"
#include "../../logger.mqh"

void OrderProcessorStops(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_OPEN_MARKET) {
      CRequestOpenMarketWithStops* req = dynamic_cast<CRequestOpenMarketWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,req.order_type);
         req.price = req.current_price;
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            double sl;
            if (req.slcalc.Calculate(req,STOP_MODE_SL,sl)) req.sl = sl;
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            double tp;
            if (req.tpcalc.Calculate(req,STOP_MODE_TP,tp)) req.tp = tp;
         }
      }
      next.ProcessOrder(request,parameters);
   } else if (request == ORDER_REQUEST_OPEN_PENDING) {
      CRequestOpenPendingWithStops* req = dynamic_cast<CRequestOpenPendingWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,req.order_type);
         if (CheckPointer(req.entrycalc) != POINTER_INVALID) {
            double price;
            if (req.entrycalc.Calculate(req,STOP_MODE_ENTRY,price)) req.price = price;
         }
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            double sl;
            if (req.slcalc.Calculate(req,STOP_MODE_SL,sl)) req.sl = sl;
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            double tp;
            if (req.tpcalc.Calculate(req,STOP_MODE_TP,tp)) req.tp = tp;
         }
      }
      next.ProcessOrder(request,parameters);
   } else if (request == ORDER_REQUEST_MODIFY_PENDING) {
      CRequestModifyPendingWithStops* req = dynamic_cast<CRequestModifyPendingWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,(ENUM_ORDER_TYPE)req.order_details.GetOrderType());
         bool modify = false;
         if (CheckPointer(req.entrycalc) != POINTER_INVALID) {
            req.price = req.order_details.GetEntryPrice();
            modify = modify || req.entrycalc.Calculate(req,STOP_MODE_ENTRY,req.price);
         }
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            req.sl = req.order_details.GetStoploss();
            modify = modify || req.slcalc.Calculate(req,STOP_MODE_SL,req.sl);
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            req.tp = req.order_details.GetTakeprofit();
            modify = modify || req.tpcalc.Calculate(req,STOP_MODE_TP,req.tp);
         }
         if (modify) next.ProcessOrder(request,parameters);
      } else {
         next.ProcessOrder(request,parameters);
      }
   } else if (request == ORDER_REQUEST_MODIFY_MARKET) {
      CRequestModifyPositionWithStops* req = dynamic_cast<CRequestModifyPositionWithStops*>(parameters);
      if (req != NULL) {
         req.current_price = GetPrice(req.symbol,(ENUM_ORDER_TYPE)req.position_details.GetPositionType());
         bool modify = false;
         if (CheckPointer(req.slcalc) != POINTER_INVALID) {
            req.sl = req.position_details.GetStoploss();
            modify = modify || req.slcalc.Calculate(req,STOP_MODE_SL,req.sl);
         }
         if (CheckPointer(req.tpcalc) != POINTER_INVALID) {
            req.tp = req.position_details.GetTakeprofit();
            modify = modify || req.tpcalc.Calculate(req,STOP_MODE_TP,req.tp);
         }
         if (modify) next.ProcessOrder(request,parameters);
      } else {
         next.ProcessOrder(request,parameters);
      }
   } else {
      next.ProcessOrder(request,parameters);
   }
}
