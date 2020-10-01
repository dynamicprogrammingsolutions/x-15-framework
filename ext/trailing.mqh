#property strict

#include "../orders/symbols.mqh"
#include "../orders/share/position_details.mqh"
#include "../orders/modify_position/request_modify_position.mqh"
#include "../orders/order_processor_register.mqh"

typedef bool (*CalcTrailingFunc)(void* params, CSymbol* sym, double in_profit, double sl, double& newsl);

void TrailingSL(void* params, CSymbol* _symbol, CPositionDetails* pos, CalcTrailingFunc calc_trailing) {
   double in_profit = GetDiff(STOP_MODE_PROFIT,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),GetClosePrice(_symbol,(ENUM_ORDER_TYPE)pos.GetPositionType()));
   double newsl = 0;
   double sl = GetDiff(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),pos.GetStoploss());
   if (calc_trailing(params,_symbol,in_profit,sl,newsl)) {
      double slprice = AddToStop(STOP_MODE_SL,(ENUM_ORDER_TYPE)pos.GetPositionType(),pos.GetEntryPrice(),newsl);
      __trailing_modify_sl(_symbol,pos,slprice);
   }
}

void __trailing_modify_sl(CSymbol* _symbol, CPositionDetails* pos, double sl) {
   CRequestModifyPosition req;
   req.symbol = _symbol;
   req.order_id = pos.GetId();
   req.tp = pos.GetTakeprofit();
   req.sl = sl;
   ProcessOrder(ORDER_REQUEST_MODIFY_POSITION,GetPointer(req));
}

class CTrailingParamsDefault {
public:
   int breakevenat_ticks;
   int breakeven_profit_ticks;
   int trailingstop_activate_ticks;
   int trailingstop_ticks;
   int stoptrailing_ticks;
};

bool CalcTrailingDefault(void* params, CSymbol* sym, double in_profit, double sl, double& newsl) {
   CTrailingParamsDefault* trailingparams = (CTrailingParamsDefault*)params;
   
   double be = sym.PriceRound(trailingparams.breakevenat_ticks*sym.TickSize());
   double be_profit = sym.PriceRound(trailingparams.breakeven_profit_ticks*sym.TickSize());
   double ts = sym.PriceRound(trailingparams.trailingstop_ticks*sym.TickSize());
   double ts_activate = sym.PriceRound(trailingparams.trailingstop_activate_ticks*sym.TickSize());
   double stopts = sym.PriceRound(trailingparams.stoptrailing_ticks*sym.TickSize());
   
   newsl = sl;
   
   if (be != 0 && in_profit >= be) {
      newsl = MathMin(newsl,-be_profit);
   }
   
   if (ts != 0 && in_profit >= ts_activate) {
      if (stopts != 0 && in_profit >= stopts) {
         newsl = MathMin(newsl,-(stopts-ts));
      } else {
         newsl = MathMin(newsl,-(in_profit-ts));
      }
   }
   
   newsl = sym.PriceRound(newsl);

   sl = NormalizeDouble(sl,8);
   newsl = NormalizeDouble(newsl,8);
   
   if (sl != newsl) {
      debug(("TS: old sl: ",sl," new sl: ",newsl));
   }
   
   return sl != newsl;
   
}