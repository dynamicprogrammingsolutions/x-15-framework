//+------------------------------------------------------------------+
//|                                                      symbols.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#ifndef FRACTIONAL_TRESHOLD
#define FRACTIONAL_TRESHOLD 50000
#endif

class CSymbol {
public:
   double ask;
   double bid;
   string symbol;
   double ticksize;
   double lotstep;
   double maxlot;
   double minlot;
   CSymbol(const string _symbol) :
      symbol(_symbol),
      ask(0),
      bid(0),
      ticksize(0),
      lotstep(0),
      maxlot(0),
      minlot(0)
   {}
   virtual string Name() { return NULL; }
   virtual double Ask() { return 0; }
   virtual double Bid() { return 0; }
   virtual double TickSize() { return 0; }
   virtual double LotStep() { return 0; }
   virtual double MaxLot() { return 0; }
   virtual double MinLot() { return 0; }
   virtual double LotRound(const double lotsize) { return lotsize; }
   virtual double PriceRound(const double price) { return price; }
   virtual bool IsFractional() { return false; }
};

#ifdef __MQL4__


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

class CSymbolImpl : public CSymbol {
public:
   CSymbolImpl(const string _symbol) : CSymbol(_symbol) {}
   virtual string Name() {
      if (symbol == NULL) return _Symbol;
      else return symbol;
   }
   virtual double Ask() { ask = SymbolInfoDouble(symbol,SYMBOL_ASK); return ask; }
   virtual double Bid() { bid = SymbolInfoDouble(symbol,SYMBOL_BID); return bid; }
   virtual double TickSize() {
      if (ticksize==0) ticksize = MarketInfo(symbol,MODE_TICKSIZE);
      return ticksize;
   }
   virtual double LotStep() {
      if (lotstep==0) lotstep = MarketInfo(symbol,MODE_LOTSTEP);
      return lotstep;
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
      return lotsize;  
   }
   virtual double PriceRound(const double price) {
      double ticksie = TickSize();
      return MathRound(price/ticksize)*ticksize;
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

/*double ask(const string symbol) {
   return SymbolInfoDouble(symbol,SYMBOL_ASK);
}

double bid(const string symbol) {
   return SymbolInfoDouble(symbol,SYMBOL_BID);
}

double ask(CSymbol* symbol) {
   return SymbolInfoDouble(symbol.symbol,SYMBOL_ASK);
}

double bid(CSymbol* symbol) {
   return SymbolInfoDouble(symbol.symbol,SYMBOL_BID);
}

double ticksize(const string symbol) {
   return MarketInfo(symbol,MODE_TICKSIZE);
}

double ticksize(CSymbol* symbol) {
   return MarketInfo(symbol.symbol,MODE_TICKSIZE);
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

double LotRound(CSymbol* symbol, double lotsize) {
   return LotRound(symbol.symbol,lotsize);
}

double SymbolIsFractional(const string symbol) {
   return bid(symbol)/ticksize(symbol) > FRACTIONAL_TRESHOLD;
}*/

#endif

#ifdef __MQL5__




#endif

int ConvertParamToFractional(CSymbol* symbol, double value) {
   if (symbol.IsFractional()) return (int)(value*10);
   else return (int)value;
}