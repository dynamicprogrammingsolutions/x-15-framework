#include "trailing.mqh"
#include "../orders/share/errordescription.mqh"
#include "../orders/stops.mqh"

/*
Usage:
   tsparams = new CTrailingParamsStopcalcDefault();
   tsparams.breakevenat_ticks = breakevenat;
   tsparams.breakeven_profit_ticks = breakeven_profit;
   tsparams.trailingstop_activate_ticks = trailingstop_activate;
   tsparams.trailingstop_ticks = trailingstop;
   tsparams.stoptrailing_ticks = stoptrailing;
   tsparams.breakevenat_ticks = breakevenat;

   CStop* ts;
   ts = GetStopCalc(tsparams,TrailingStopcalcDefault,STOP_MODE_SL);
   CIteratorObj<CPositionDetails>* position_iter = GetPositionsIterator();
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();;
      TrailingSLByStopcalc(pos,ts);
   }
*/

CalcTrailingFunc __CalcTrailingFunction = CalcTrailingDefault;


bool TrailingStopcalcDefault(void* params, CStopRequest* stopreq, CRequest* originalreq, double& result) {
   if (stopreq.stopmode != STOP_MODE_SL || originalreq.Type() != ORDER_REQUEST_MODIFY_POSITION) return false;
   
   CRequestModifyPosition* req = originalreq;
   CPositionDetails* pos = req.position_details;
   CSymbol* _symbol = req.symbol;
   
   double in_profit = _symbol.PriceRound(GetDiff(STOP_MODE_PROFIT,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),GetClosePrice(_symbol,(ENUM_ORDER_TYPE)pos.GetPositionType())));
   double newsl = 0;
   double sl = _symbol.PriceRound(GetDiff(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),pos.GetStoploss()));
   
   if (__CalcTrailingFunction(params,_symbol,in_profit,sl,newsl)) {
      result = AddToStop(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),newsl);
      debug(("trail sl of ",pos.GetId()," new sl: ",result));
      return true;
   }
   
   return false;
}

void TrailingSLByStopcalc(CPositionDetails* pos, CStop* ts_calc) {
   CRequestModifyPositionWithStops req;
   req.order_id = pos.GetId();
   req.position_details = pos;
   req.symbol = pos.GetCSymbol();
   req.slcalc = ts_calc;
   ProcessOrder(ORDER_REQUEST_MODIFY_POSITION,GetPointer(req));
   if (req.error > 1) {
      print(("Couldn't modify SL of order ",req.order_id," Error: ",req.error," ",ErrorDescription(req.error)));
   }
}