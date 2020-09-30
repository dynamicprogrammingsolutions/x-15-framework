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

#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/pending_orders.mqh>
#include <x-15-0.1/orders/filters.mqh>

#include <x-15-0.1/comments.mqh>
#include <x-15-0.1/logger.mqh>

#include <x-15-0.1/ext/tickcounter.mqh>

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
input int magic = 1;
input bool order_by_market = false;

input double close_at_profit = 5;

double stoploss_ticks;
double takeprofit_ticks;
double entry_ticks;

CSymbol* _symbol;

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

   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete _symbol;
   
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
   CIteratorObj<CPositionDetails>* position_iter = get_positions_iterator();
   double buyprofit = 0;
   double sellprofit = 0;
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();
      addcommentln("open position: ",pos.GetId()," ",EnumToString(pos.GetPositionType())," profit: ",pos.GetProfit());
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


CIteratorObj<CPositionDetails>* get_positions_iterator() {
   CRequestSelectPositions req;
   req.filter_by_symbol = true;
   req.magic = magic;
   req.symbol = _symbol;
   req.filter = ORDER_FILTER_MARKET;
   ProcessOrder(ORDER_REQUEST_SELECT_POSITIONS,GetPointer(req));
   return req.iterator;
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
   CRequestOpenMarket req;
   req.symbol = _symbol;
   req.magic = magic;
   req.volume = lotsize;
   req.order_type = ORDER_TYPE_BUY;
   req.price = GetPrice(req.symbol,req.order_type);
   req.sl = AddToLoss(req.order_type,req.price,stoploss_ticks*req.symbol.TickSize());
   req.tp = AddToProfit(req.order_type,req.price,takeprofit_ticks*req.symbol.TickSize());
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);
}


void _open_sell_market() {
   CRequestOpenMarket req;
   req.symbol = _symbol;
   req.magic = magic;
   req.volume = lotsize;
   req.order_type = ORDER_TYPE_SELL;
   req.price = GetPrice(req.symbol,req.order_type);
   req.sl = AddToLoss(req.order_type,req.price,stoploss_ticks*req.symbol.TickSize());
   req.tp = AddToProfit(req.order_type,req.price,takeprofit_ticks*req.symbol.TickSize());
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);
}

void _open_buy_pending() {
   CRequestOpenPending req;
   req.symbol = _symbol;
   req.magic = magic;
   req.volume = lotsize;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: req.order_type = ORDER_TYPE_BUY_LIMIT; break;
      case ENTRY_STOP: req.order_type = ORDER_TYPE_BUY_STOP; break;
   }
   req.current_price = GetPrice(req.symbol,req.order_type);
   req.price = AddToStop(STOP_MODE_ENTRY,req.order_type,req.current_price,entry_ticks*req.symbol.TickSize());
   req.sl = AddToLoss(req.order_type,req.price,stoploss_ticks*req.symbol.TickSize());
   req.tp = AddToProfit(req.order_type,req.price,takeprofit_ticks*req.symbol.TickSize());
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   Print("return ticket: ",req.ticket);  
}

void _open_sell_pending() {
   CRequestOpenPending req;
   req.symbol = _symbol;
   req.magic = magic;
   req.volume = lotsize;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: req.order_type = ORDER_TYPE_SELL_LIMIT; break;
      case ENTRY_STOP: req.order_type = ORDER_TYPE_SELL_STOP; break;
   }
   req.current_price = GetPrice(req.symbol,req.order_type);
   req.price = AddToStop(STOP_MODE_ENTRY,req.order_type,req.current_price,entry_ticks*req.symbol.TickSize());
   req.sl = AddToLoss(req.order_type,req.price,stoploss_ticks*req.symbol.TickSize());
   req.tp = AddToProfit(req.order_type,req.price,takeprofit_ticks*req.symbol.TickSize());
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   Print("return ticket: ",req.ticket);  
}



void close_callback(int order_ticket, bool success, int error) {
   if (!success) {
      Print("close error: ",ErrorDescription(error));
   }
}

void close_buy() {
   CRequestCloseAll req;
   req.symbol = _symbol;
   req.filter = ORDER_FILTER_LONG;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void close_sell() {
   CRequestCloseAll req;
   req.symbol = _symbol;
   req.filter = ORDER_FILTER_SHORT;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}


void OnTimer()
{

}
