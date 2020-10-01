#include "trailing.mqh"
#include "../orders/share/errordescription.mqh"
#include "../orders/stops.mqh"

/*
Usage:

   
   input double breakevenat = 0;
   input double breakeven_profit = 0;
   input double trailingstop_activate = 0;
   input double trailingstop = 0;
   input double stoptrailing = 0;

   tsparams = new CTrailingStopcalc();
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);
   tsparams.breakeven_profit_ticks = ConvertParamToFractional(_symbol,breakeven_profit);
   tsparams.trailingstop_activate_ticks = ConvertParamToFractional(_symbol,trailingstop_activate);
   tsparams.trailingstop_ticks = ConvertParamToFractional(_symbol,trailingstop);
   tsparams.stoptrailing_ticks = ConvertParamToFractional(_symbol,stoptrailing);
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);

   CStop* ts;
   ts = new CTrailingStopcalc(tsparams,CalcTrailingDefault);
   CIteratorObj<CPositionDetails>* position_iter = GetPositionsIterator();
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();;
      TrailingSLByStopcalc(pos,ts);
   }
*/

CalcTrailingFunc __CalcTrailingFunction = CalcTrailingDefault;

class CTrailingStopcalc : public CStop {
   CalcTrailingFunc m_fn;
   ENUM_STOP_MODE m_stopmode;
   void* m_params;
public:
   CTrailingStopcalc(void* params, CalcTrailingFunc trailing_calc_fn) : m_params(params), m_fn(trailing_calc_fn), m_stopmode(STOP_MODE_SL) {
      
   }
   ~CTrailingStopcalc() {
      if (CheckPointer(m_params) == POINTER_DYNAMIC) delete m_params;
   }
   virtual bool Calculate(CRequest* request, ENUM_STOP_MODE stopmode, double& result) {
      if (stopmode != m_stopmode || request.Type() != ORDER_REQUEST_MODIFY_POSITION) return false;
      if (InstanceOf<CRequestModifyPosition>(request)) {
         CStopRequest stoprequest((CRequestModifyPosition*)request,m_stopmode);
         stoprequest.stopmode = m_stopmode;
         return TrailingStop(m_params,GetPointer(stoprequest),request,result);
      }
      return false;
   }
   virtual bool TrailingStop(void* params, CStopRequest* stopreq, CRequest* originalreq, double& result) {
   
      CRequestModifyPosition* req = originalreq;
      CPositionDetails* pos = req.position_details;
      CSymbol* _symbol = req.symbol;
      
      double in_profit = _symbol.PriceRound(GetDiff(STOP_MODE_PROFIT,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),GetClosePrice(_symbol,(ENUM_ORDER_TYPE)pos.GetPositionType())));
      double newsl = 0;
      double sl = _symbol.PriceRound(GetDiff(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),pos.GetStoploss()));
      
      if (m_fn(params,_symbol,in_profit,sl,newsl)) {
         result = AddToStop(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),newsl);
         debug(("trail sl of ",pos.GetId()," new sl: ",result));
         return true;
      }
      
      return false;
   }
};

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