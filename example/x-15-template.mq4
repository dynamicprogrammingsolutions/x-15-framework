//* Copyright notice: This software and it's parts including any included files, except the anything from the "lib" directory is made by and is property of Dynamic Programming Solutions Corporation,
//* while the strategy elements used in it is property of the customer. Any parts can be reused in later software which doesn't violate our Non-Disclosure Agreement.
//* 
//* Non-Disclosure Agreement:
//* We pledge to hold your trading system in confidence.
//* We will not resell your expert advisor that contains your trading ideas, nor will we publish your system specifications.
//* Receipt of your system specifications or other intellectual property by us will effectively constitute a Non-Disclosure Agreement.
//* We have no obligation with respect to such information where the information:
//* 1) was known to us prior to receiving any of the Confidential Information from the customer;
//* 2) has become publicly known through no wrongful act of Recipient;
//* 3) was received by us without breach of this Agreement from a third party without restriction as to the use and disclosure of the information;
//* 4) was independently developed by us without use of the Confidential Information 
//* 
//* The customer has the following rights:
//* 1) Use the software in any instances for personal matters
//* 2) Learn the code and change it
//* 3) Ask any other programmer to make changes, under Non-Disclosure Agreement on the usage of the source code.
//* 4) Resell this EA with possibility to provide the source code under Non-Disclosure Agreement.
//* 5) Make this sofwtare available on website as a free downloadable product WITHOUT providing the source code (i.e. only the ex4 file is downloadable)

#define NAME "x-15-template"
#define VERSION "1.2"

#property copyright "Dynamic Programming Solutions Corp."
#property link      "http://www.metatraderprogrammer.com"
#property strict
#property version VERSION

#define ENABLE_DEBUG

#include <x-15-0.1/signals.mqh>
#include <x-15-0.1/tradesignal.mqh>
#include <x-15-0.1/ext/signal_wrapper.mqh>
#include <x-15-0.1/ext/tickcounter.mqh>
#include <x-15-0.1/ext/filters/trade_only_firsttick.mqh>
#include <x-15-0.1/ext/filters/trade_only_signal_change.mqh>
#include <x-15-0.1/ext/trailing_stopscalc_oop.mqh>

#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/pending_orders.mqh>
#include <x-15-0.1/orders/stops.mqh>
#include <x-15-0.1/orders/moneymanagement.mqh>
#include <x-15-0.1/orders/filters.mqh>
#include <x-15-0.1/orders/order_helper.mqh>

#include <x-15-0.1/comments.mqh>
#include <x-15-0.1/logger.mqh>
#include <x-15-0.1/collections.mqh>

enum ENUM_ENTRY_TYPE {
   ENTRY_LIMIT,
   ENTRY_STOP
};

input double lotsize = 0.1;
input bool open_pending = false;
input ENUM_ENTRY_TYPE pending_entry_type = ENTRY_LIMIT;
input double entry = 10;
input double stoploss = 20;
input double takeprofit = 20;

input double breakevenat = 10;
input double breakeven_profit = 5;
input double trailingstop_activate = 15;
input double trailingstop = 5;
input double stoptrailing = 25;

int entry_ticks;
int stoploss_ticks;
int takeprofit_ticks;

input int magic = 1;
input bool order_by_market = false;

int signal_candle_color(int bar) {
   if (Close[bar] > Open[bar]) return SIGNAL_BUY;
   if (Close[bar] < Open[bar]) return SIGNAL_SELL;
   return SIGNAL_NO;
}

int signal_macd(int bar) {
   double macd = iMACD(NULL,0,21,14,3,PRICE_CLOSE,MODE_SIGNAL,bar);
   if (macd > 0) return SIGNAL_BUY;
   if (macd < 0) return SIGNAL_SELL;
   return SIGNAL_NO;
}

CSignal<int,int>* signal_with_filters;

int get_signal() {
   return signal_with_filters.Run(1);
}

CStop* slcalc;
CStop* tpcalc;
CStop* entrycalc;
CMoneyManagement* mm;
CStop* ts;

int OnInit()
{

   _symbol = GetSymbol(NULL);
   _magic = magic;
   
   #ifdef __MQL4__
      __order_by_market = order_by_market;
   #endif

   RegisterMarketOrderProcessors();
   RegisterPendingOrderProcessors();
   RegisterStandardOrderFilters();

   signal_with_filters = WrapSignal("Main Signal",signal_and(WrapSignal("Candle Color",CreateSignal(signal_candle_color)),WrapSignal("MACD",CreateSignal(signal_macd))));
   signal_with_filters = add_filter(signal_with_filters,new CFilterTradeOnlyFirsttick<int,int>());
   signal_with_filters = add_filter(signal_with_filters,new CFilterTradeOnlySignalChange<int,int>());
   
   stoploss_ticks = ConvertParamToFractional(_symbol,stoploss);
   takeprofit_ticks = ConvertParamToFractional(_symbol,takeprofit);
   entry_ticks = ConvertParamToFractional(_symbol,entry);

   slcalc = new CStopTicks(stoploss_ticks);
   tpcalc = new CStopTicks(takeprofit_ticks);
   entrycalc = new CStopTicks(entry_ticks);
   mm = new CMMFixed(lotsize);
   
   
   CTrailingParamsDefault* tsparams = new CTrailingParamsDefault();
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);
   tsparams.breakeven_profit_ticks = ConvertParamToFractional(_symbol,breakeven_profit);
   tsparams.trailingstop_activate_ticks = ConvertParamToFractional(_symbol,trailingstop_activate);
   tsparams.trailingstop_ticks = ConvertParamToFractional(_symbol,trailingstop);
   tsparams.stoptrailing_ticks = ConvertParamToFractional(_symbol,stoptrailing);
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);
   ts = new CTrailingStopcalc(tsparams,CalcTrailingDefault);

   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   DeregisterOrderProcessors();

   delete signal_with_filters;
   delete _symbol;
   delete slcalc;
   delete tpcalc;
   delete entrycalc;
   delete mm;
   delete ts;
   
   EventKillTimer();
   
}


void OnTick()
{
   count_tick();
   ENUM_SIGNAL signal = (ENUM_SIGNAL)get_signal();

   manage_positions();

   switch(signal) {
      case SIGNAL_BUY:
         print(("New Signal: Buy"));
         process_buy();
         break;
      case SIGNAL_SELL:
         print(("New Signal: Sell"));
         process_sell();
         break;
   }
   
   signal_with_filters.OnTick();
   
   writecomment();
   delcomment();
   
}

#include <x-15-0.1/ext/trailing.mqh>

void manage_positions() {
   CIteratorObj<CPositionDetails>* position_iter = GetPositionsIterator();
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();
      addcommentln("open position: ",pos.GetId());
      TrailingSLByStopcalc(pos,ts);
   }
}

void process_buy() {
   close_sell();
   if (open_pending) cancel_short();
   if (cnt_buy() > 0) return;
   open_buy();
}

void process_sell() {
   close_buy();
   if (open_pending) cancel_long();
   if (cnt_sell() > 0) return;
   open_sell();
}

int cnt_buy() {
   return CntOrders(ORDER_FILTER_LONG);
}

int cnt_sell() {
   return CntOrders(ORDER_FILTER_SHORT);
}

void open_buy() {
   if (open_pending) {
      _open_buy_pending();
   } else {
      _open_buy_market();
   }
}

void open_sell() {
   if (open_pending) {
      _open_sell_pending();
   } else {
      _open_sell_market();
   }
}

void _open_buy_market() {
   int ticket = OpenMarketOrder(ORDER_TYPE_BUY,mm,slcalc,tpcalc);
   print(("return ticket: ",ticket));
}

void _open_sell_market() {
   int ticket = OpenMarketOrder(ORDER_TYPE_SELL,mm,slcalc,tpcalc);
   print(("return ticket: ",ticket));
}

void _open_buy_pending() {
   ENUM_ORDER_TYPE type = -1;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: type = ORDER_TYPE_BUY_LIMIT; break;
      case ENTRY_STOP: type = ORDER_TYPE_BUY_STOP; break;
   }
   int ticket = OpenPendingOrder(type,mm,entrycalc,slcalc,tpcalc);
   print(("return ticket: ",ticket));
}

void _open_sell_pending() {
   ENUM_ORDER_TYPE type = -1;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: type = ORDER_TYPE_SELL_LIMIT; break;
      case ENTRY_STOP: type = ORDER_TYPE_SELL_STOP; break;
   }
   int ticket = OpenPendingOrder(type,mm,entrycalc,slcalc,tpcalc);
   print(("return ticket: ",ticket));
}


void close_buy() {
   CloseAll(ORDER_FILTER_LONG);
}

void close_sell() {
   CloseAll(ORDER_FILTER_SHORT);
}

void cancel_long() {
   CancelAll(ORDER_FILTER_LONG);
}

void cancel_short() {
   CancelAll(ORDER_FILTER_SHORT);
}

void OnTimer()
{

}
