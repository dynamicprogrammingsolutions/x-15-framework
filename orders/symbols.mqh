//+------------------------------------------------------------------+
//|                                                      symbols.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "../logger.mqh"

#ifndef FRACTIONAL_TRESHOLD
#define FRACTIONAL_TRESHOLD 50000
#endif

class CSymbol {
protected:
   CSymbol(const string _symbol) :
      symbol(_symbol),
      ask(0),
      bid(0),
      ticksize(0),
      lotstep(0),
      maxlot(0),
      minlot(0),
      point(0)
   {}
public:
   double ask;
   double bid;
   string symbol;
   double ticksize;
   double lotstep;
   double maxlot;
   double minlot;
   double point;
   double tickvalue;
   virtual string Name() { return NULL; }
   virtual double Ask() { return 0; }
   virtual double Bid() { return 0; }
   virtual int Spread() { return 0; }
   virtual double TickSize() { return 0; }
   virtual double LotStep() { return 0; }
   virtual double TickValue() { return 0; }
   virtual double MaxLot() { return 0; }
   virtual double MinLot() { return 0; }
   virtual double Point() { return 0; }
   virtual int StopLevel() { return 0; }
   virtual double LotRound(const double lotsize) { return lotsize; }
   virtual double PriceRound(const double price) { return price; }
   virtual bool IsFractional() { return false; }
};

#ifdef __MQL4__



class CSymbolImpl : public CSymbol {
public:
   CSymbolImpl(const string _symbol) : CSymbol(_symbol) {
      if (_symbol == "") symbol = NULL;
   }
   void SetSymbol(const string _symbol) {
      if (_symbol != this.symbol) {
         this.symbol = _symbol;
         ticksize = 0;
         lotstep = 0;
         maxlot = 0;
         minlot = 0;
         point = 0;
      }
   }
   virtual string Name() {
      if (symbol == NULL) return _Symbol;
      else return symbol;
   }
   virtual double Ask() { ask = SymbolInfoDouble(symbol,SYMBOL_ASK); return ask; }
   virtual double Bid() { bid = SymbolInfoDouble(symbol,SYMBOL_BID); return bid; }
   virtual double TickSize() {
      if (ticksize==0) ticksize = MarketInfo(symbol,MODE_TICKSIZE);
      if (ticksize == 0) {
         print(("Invalid ticksize for symbol "+symbol));
         return 1;
      } else {
         return ticksize;
      }
   }
   virtual int InTicks(double price) {
      return (int)MathRound(price/this.TickSize());
   }
   virtual double Point() {
      if (point==0) point = SymbolInfoDouble(symbol,SYMBOL_POINT);
      return point;
   }
   virtual double LotStep() {
      if (lotstep==0) lotstep = MarketInfo(symbol,MODE_LOTSTEP);
      return lotstep;
   }
   virtual double TickValue() {
      if (tickvalue==0) tickvalue = MarketInfo(symbol,MODE_TICKVALUE);
      return tickvalue;
   }
   virtual double MaxLot() {
      if (maxlot==0) maxlot = MarketInfo(symbol,MODE_MAXLOT);
      return maxlot;
   }
   virtual double MinLot() {
      if (minlot==0) minlot = MarketInfo(symbol,MODE_MINLOT);
      return minlot;
   }
   virtual double LotRound(const double lotsize) {
      double step = LotStep();
      double result_lots = MathRound(lotsize/step)*step;
      result_lots = MathMax(result_lots,MinLot());
      result_lots = MathMin(result_lots,MaxLot());
      return result_lots;  
   }
   virtual int StopLevel() {
      return (int)MarketInfo(symbol,MODE_STOPLEVEL);
   }
   virtual int Spread() {
      return (int)MarketInfo(symbol,MODE_SPREAD);
   }
   virtual double PriceRound(const double price) {
      double __ticksize = TickSize();
      return NormalizeDouble(((int)MathRound(price/__ticksize))*__ticksize,(int)MarketInfo(symbol,MODE_DIGITS));
   }
   virtual bool IsFractional() {
      return Bid()/TickSize() > FRACTIONAL_TRESHOLD;
   }
};

CSymbol* GetSymbol(const string symbol) {
   return new CSymbolImpl(symbol);
}

CSymbol* __defaultSymbol;

CSymbol* GetDefaultSymbol() {
   return new CSymbolImpl(NULL);
}


#endif

#ifdef __MQL5__




#endif

int ConvertParamToFractional(CSymbol* symbol, double value) {
   if (symbol.IsFractional()) return (int)(value*10);
   else return (int)value;
}

double ConvertFractionalParamToPrice(CSymbol* symbol, double value) {
   return symbol.PriceRound(ConvertParamToFractional(symbol,value)*symbol.TickSize());
}

enum ENUM_STOP_MODE {
   STOP_MODE_SL,
   STOP_MODE_TP,
   STOP_MODE_PROFIT,
   STOP_MODE_LOSS,
   STOP_MODE_ENTRY
};

double GetPrice(CSymbol* symbol, ENUM_ORDER_TYPE order_type) {
   if (CheckPointer(symbol) == POINTER_INVALID) symbol = __defaultSymbol;
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return symbol.Ask();
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return symbol.Bid();
      default:
         return 0;
   }
}

double GetClosePrice(CSymbol* symbol, ENUM_ORDER_TYPE order_type) {
   if (CheckPointer(symbol) == POINTER_INVALID) symbol = __defaultSymbol;
   switch(order_type) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return symbol.Ask();
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return symbol.Bid();
      default:
         return 0;
   }
}

double GetDiffProfit(ENUM_ORDER_TYPE order_type, double price, double priceto) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return NormalizeDouble(priceto - price,8);
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return NormalizeDouble(price - priceto,8);
      default:
         return 0;
   }
}

double GetDiffLoss(ENUM_ORDER_TYPE order_type, double price, double priceto) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return NormalizeDouble(price - priceto,8);
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return NormalizeDouble(priceto - price,8);
      default:
         return 0;
   }
}

bool IsProfitReached(CSymbol* symbol, ENUM_ORDER_TYPE order_type, double price) {
   switch(order_type) {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
         return symbol.Bid() >= price;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         return symbol.Ask() <=  price;
      default:
         return false;
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


double AddToStop(ENUM_STOP_MODE stopmode, ENUM_ORDER_TYPE order_type, double price, double diff) {
   switch (stopmode) {
      case STOP_MODE_SL:
      case STOP_MODE_LOSS:
         return AddToLoss(order_type,price,diff);
      case STOP_MODE_TP:
      case STOP_MODE_PROFIT:
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

double GetDiff(ENUM_STOP_MODE stopmode, ENUM_ORDER_TYPE order_type, double price, double priceto) {
   switch (stopmode) {
      case STOP_MODE_SL:
      case STOP_MODE_LOSS:
         return GetDiffLoss(order_type,price,priceto);
      case STOP_MODE_TP:
      case STOP_MODE_PROFIT:
         return GetDiffProfit(order_type,price,priceto);
      case STOP_MODE_ENTRY:
         switch(order_type) {
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_SELL_STOP:
               return GetDiffProfit(order_type,price,priceto);
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_SELL_LIMIT:
               return GetDiffLoss(order_type,price,priceto);
         }
   }
   return 0;
}