//+------------------------------------------------------------------+
//|                                                      symbols.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "order_filters.mqh"
#include "..\generic_collections\ArrayList.mqh"
#include "..\generic_collections\HashMap.mqh"

#ifdef __MQL4__

double GetPrice(const string symbol, ENUM_ORDER_TYPE order_type) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return ask(symbol);
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return bid(symbol);
      default:
         return 0;
   }
}

double GetClosePrice(const string symbol, ENUM_ORDER_TYPE order_type) {
   switch(order_type) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return ask(symbol);
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return bid(symbol);
      default:
         return 0;
   }
}

double AddToProfit(ENUM_ORDER_TYPE order_type, double price, double diff) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return price + diff;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return price - diff;
      default:
         return 0;
   }
}

double AddToLoss(ENUM_ORDER_TYPE order_type, double price, double diff) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return price - diff;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return price + diff;
      default:
         return 0;
   }
}

class CSymbol {
public:
   string symbol;
   double ticksize;
   double lotstep;
   double maxlot;
   double minlot;
   CSymbol(): ticksize(0) { }
};

#include "..\collections.mqh"
CMapPrimitive<string,int> __symbolIds;
CSymbol __symbols[1];
int __symbols_count;
#define CAPACITY_INCREASE_BY 10

int GetSymbolId(const string symbol) {
   int id;
   if (symbol != NULL) {
      int idx = __symbolIds.GetIdxByKey(symbol);
      if (idx != -1) {
         return __symbolIds.GetByIdx(idx);
      } else {
         if (ArraySize(__symbols)==__symbols_count) {
            ArrayResize(__symbols,__symbols_count+CAPACITY_INCREASE_BY);
         }
         id = __symbols_count;
         __symbols_count++;
         __symbols[id].symbol = symbol;
         __symbolIds.Put(symbol,id);
         return id;
      }
   } else {
      int idx = __symbolIds.GetIdxByKey(_Symbol);
      if (idx != -1) {
         return __symbolIds.GetByIdx(idx);
      } else {
         if (ArraySize(__symbols)==__symbols_count) {
            ArrayResize(__symbols,__symbols_count+CAPACITY_INCREASE_BY);
         }
         id = __symbols_count;
         __symbols_count++;
         __symbols[id].symbol = _Symbol;
         __symbolIds.Put(_Symbol,id);
         return id;
      }
   }
}

double ask(const string symbol) {
   return SymbolInfoDouble(symbol,SYMBOL_ASK);
}

double bid(const string symbol) {
   return SymbolInfoDouble(symbol,SYMBOL_BID);
}

double ticksize(const string symbol) {
   return MarketInfo(symbol,MODE_TICKSIZE);
}

double ticksize_i(const int symbolId) {
   if (__symbols[symbolId].ticksize == 0) {
      __symbols[symbolId].ticksize = MarketInfo(__symbols[symbolId].symbol,MODE_TICKSIZE);
   }
   return __symbols[symbolId].ticksize;
}

double LotStep(const string symbol) {
   return MarketInfo(symbol,MODE_LOTSTEP);
}

double MaxLot(const string symbol) {
   return MarketInfo(symbol,MODE_MAXLOT);
}

double MinLot(const string symbol) {
   return MarketInfo(symbol,MODE_MINLOT);
}

double LotRound(const string symbol, double lotsize) {
   double step = LotStep(symbol);
   double result_lots = MathRound(lotsize/step)*step;
   result_lots = MathMax(result_lots,MinLot(symbol));
   result_lots = MathMin(result_lots,MaxLot(symbol));
   return lotsize;  
}

#define FRACTIONAL_TRESHOLD 50000
double SymbolIsFractional(const string symbol) {
   return bid(symbol)/ticksize(symbol) > FRACTIONAL_TRESHOLD;
}

int ConvertParamToFractional(const string symbol, double value) {
   if (SymbolIsFractional(symbol)) return (int)(value*10);
   else return (int)value;
}

#endif

#ifdef __MQL5__




#endif