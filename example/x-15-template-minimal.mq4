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

#define NAME "x-15-template-minimal"
#define VERSION "1.2"

#property copyright "Dynamic Programming Solutions Corp."
#property link      "http://www.metatraderprogrammer.com"
#property strict
#property version VERSION

#define ENABLE_DEBUG

#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/pending_orders.mqh>
#include <x-15-0.1/orders/filters.mqh>
#include <x-15-0.1/orders/order_helper_basic.mqh>

#include <x-15-0.1/comments.mqh>
#include <x-15-0.1/logger.mqh>

#include <x-15-0.1/ext/tickcounter.mqh>
#include <x-15-0.1/ext/trailing.mqh>

enum ENUM_ENTRY_TYPE {
   ENTRY_LIMIT,
   ENTRY_STOP
};

input bool open_pending = false;
input ENUM_ENTRY_TYPE pending_entry_type = ENTRY_LIMIT;
input double lotsize = 0.1;
input double entry = 10;
input double stoploss = 20;
input double takeprofit = 20;

input double breakevenat = 10;
input double breakeven_profit = 5;
input double trailingstop_activate = 15;
input double trailingstop = 5;
input double stoptrailing = 25;

input int magic = 1;
input bool order_by_market = false;

input double close_at_profit = 5;

double stoploss_ticks;
double takeprofit_ticks;
double entry_ticks;

CTrailingParamsDefault* tsparams;

int OnInit()
{

   _symbol = GetSymbol(NULL);
   
   #ifdef __MQL4__
      __order_by_market = order_by_market;
   #endif

   RegisterMarketOrderProcessors();
   RegisterPendingOrderProcessors();
   RegisterStandardOrderFilters();

   stoploss_ticks = ConvertParamToFractional(_symbol,stoploss);
   takeprofit_ticks = ConvertParamToFractional(_symbol,takeprofit);
   entry_ticks = ConvertParamToFractional(_symbol,entry);
   
   tsparams = new CTrailingParamsDefault();
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);
   tsparams.breakeven_profit_ticks = ConvertParamToFractional(_symbol,breakeven_profit);
   tsparams.trailingstop_activate_ticks = ConvertParamToFractional(_symbol,trailingstop_activate);
   tsparams.trailingstop_ticks = ConvertParamToFractional(_symbol,trailingstop);
   tsparams.stoptrailing_ticks = ConvertParamToFractional(_symbol,stoptrailing);
   tsparams.breakevenat_ticks = ConvertParamToFractional(_symbol,breakevenat);

   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete _symbol;
   delete tsparams;
   
   DeregisterOrderProcessors();
   
   EventKillTimer();
   
}


void OnTick()
{
   count_tick();

   manage_positions();

   if (isfirsttick()) {
      open_buy();
      open_sell();
   }
   
   writecomment();
   delcomment();
   
}

#include <x-15-0.1/ext/trailing.mqh>

void manage_positions() {
   CIteratorObj<CPositionDetails>* position_iter = GetPositionsIterator();
   double buyprofit = 0;
   double sellprofit = 0;
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();
      addcommentln("open position: ",pos.GetId()," ",EnumToString(pos.GetPositionType())," profit: ",pos.GetProfit());
      TrailingSL(tsparams,_symbol,pos,CalcTrailingDefault);
      switch(pos.GetPositionType()) {
         case ORDER_TYPE_BUY:
            buyprofit += pos.GetProfit();
            break;
         case ORDER_TYPE_SELL:
            sellprofit += pos.GetProfit();
            break;   
      }
   }
   addcommentln("total buy profit: ",buyprofit);
   addcommentln("total sell profit: ",sellprofit);
   if (buyprofit >= close_at_profit) {
      close_buy();
   }
   if (sellprofit >= close_at_profit) {
      close_sell();
   }
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
   ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
   double price = GetPrice(_symbol,order_type);
   double sl = AddToLoss(order_type,price,stoploss_ticks*_symbol.TickSize());
   double tp = AddToProfit(order_type,price,takeprofit_ticks*_symbol.TickSize());
   int ticket = OpenMarketOrder(order_type,lotsize,sl,tp);
   print(("return ticket: ",ticket));
}


void _open_sell_market() {
   ENUM_ORDER_TYPE order_type = ORDER_TYPE_SELL;
   double price = GetPrice(_symbol,order_type);
   double sl = AddToLoss(order_type,price,stoploss_ticks*_symbol.TickSize());
   double tp = AddToProfit(order_type,price,takeprofit_ticks*_symbol.TickSize());
   int ticket = OpenMarketOrder(order_type,lotsize,sl,tp);
   print(("return ticket: ",ticket));
}

void _open_buy_pending() {
   ENUM_ORDER_TYPE order_type;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: order_type = ORDER_TYPE_BUY_LIMIT; break;
      case ENTRY_STOP: order_type = ORDER_TYPE_BUY_STOP; break;
   }
   double current_price = GetPrice(_symbol,order_type);
   double price = AddToStop(STOP_MODE_ENTRY,order_type,current_price,entry_ticks*_symbol.TickSize());
   double sl = AddToLoss(order_type,price,stoploss_ticks*_symbol.TickSize());
   double tp = AddToProfit(order_type,price,takeprofit_ticks*_symbol.TickSize());
   OpenPendingOrder(order_type,lotsize,price,sl,tp);
}

void _open_sell_pending() {
   ENUM_ORDER_TYPE order_type;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: order_type = ORDER_TYPE_SELL_LIMIT; break;
      case ENTRY_STOP: order_type = ORDER_TYPE_SELL_STOP; break;
   }
   double current_price = GetPrice(_symbol,order_type);
   double price = AddToStop(STOP_MODE_ENTRY,order_type,current_price,entry_ticks*_symbol.TickSize());
   double sl = AddToLoss(order_type,price,stoploss_ticks*_symbol.TickSize());
   double tp = AddToProfit(order_type,price,takeprofit_ticks*_symbol.TickSize());
   OpenPendingOrder(order_type,lotsize,price,sl,tp);
}

void close_buy() {
   CloseAll(ORDER_FILTER_LONG);
}

void close_sell() {
   CloseAll(ORDER_FILTER_SHORT);
}


void OnTimer()
{

}
