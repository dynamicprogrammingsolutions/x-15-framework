#property strict

#include "..\orders\symbols.mqh"
#include "..\orders\share\position_details.mqh"
#include "..\orders\modify_position\request_modify_position.mqh"
#include "..\orders\order_processor_register.mqh"

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