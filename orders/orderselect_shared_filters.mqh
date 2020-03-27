//+------------------------------------------------------------------+
//|                                   orderselect_shared_filters.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "symbols.mqh"
#include "order_filters.mqh"

bool __FilterByMagicNumber(int magic, int filter_magic) {
   if (filter_magic < 0) return true;
   else return magic == filter_magic;
}


#ifdef __MQL4__

bool __FilterBySymbol(const string symbol, CSymbol* filter_symbol) {
   if (filter_symbol.symbol == NULL) {
      return symbol == _Symbol;
   } else {
      return symbol == filter_symbol.symbol;
   }
}


#endif

#ifdef __MQL5__

bool __FilterBySymbol(const string symbol, const string filter_symbol) {
   if (filter_symbol == NULL || filter_symbol == "") {
      return symbol == _Symbol;
   } else {
      return symbol == filter_symbol;
   }
}

#endif