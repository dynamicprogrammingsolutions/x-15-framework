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

#include <x-15-0.1/main.mqh>
#include <x-15-0.1/signals.mqh>
#include <x-15-0.1/tradesignal.mqh>

#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/market_orders.mqh>
#include <x-15-0.1/orders/pending_orders.mqh>
#include <x-15-0.1/orders/filters.mqh>
#include <x-15-0.1/orders/stops.mqh>
#include <x-15-0.1/orders/moneymanagement.mqh>

#include <x-15-0.1/comments.mqh>
#include <x-15-0.1/logger.mqh>

#include <x-15-0.1/ext/tickcounter.mqh>
#include <x-15-0.1/ext/filters/trade_only_firsttick.mqh>
#include <x-15-0.1/ext/filters/trade_only_signal_change.mqh>
#include <x-15-0.1/ext/signal_data.mqh>

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

input double trailingstop = 20;

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

class CSignalWrapper : public CSignal<int,int> {
protected:
   CSignal<int,int>* m_delegate;

public:
   datetime lastrun;
   bool did_run;
   int signal;
   int last_execution_type;
   string signal_name;

public:
   CSignalWrapper(CSignal<int,int>* delegate, string signal_name) : m_delegate(delegate), signal_name(signal_name) {
      AttachPtr(m_delegate);
   }
   ~CSignalWrapper() {
      DetachPtr(m_delegate);
   }
   virtual int Run(int bar) {
      this.last_execution_type = SIGNAL_EXECUTION_RUN;
      this.did_run = true;
      this.signal = m_delegate.Run(bar);
      this.lastrun = TimeCurrent();
      return this.signal;
   }
   virtual void OnTick() {
      if (this.last_execution_type == SIGNAL_EXECUTION_ONTICK) this.did_run = false;
      this.last_execution_type = SIGNAL_EXECUTION_ONTICK;
      m_delegate.OnTick();
      addcommentln(this.signal_name,": ",SignalToString(this.signal)," lastrun: ",TimeToString(this.lastrun));
   }
};

CSignal<int,int>* WrapSignal(string name, CSignal<int,int>* signal) {
   return new CSignalWrapper(signal,name);
}

/*
void writedata(CSignalData* state) {
   addcommentln(state.signal_name," Signal: ",SignalToString(state.signal));
}

void writedata_main(CSignalData* state) {
   addcomment("Main Signal: ",SignalToString(state.signal)," lastrun: ",TimeToString(state.lastrun),"\n");
}

CSignal<int,int>* WrapSignal(CSignal<int,int>* signal, string name) {
   return new CWrapperWriteData(new CWrapperSaveData(signal,name),writedata); 
}

CSignal<int,int>* WrapSignalMain(CSignal<int,int>* signal) {
   return new CWrapperWriteData(new CWrapperSaveData(signal,"Main"),writedata_main); 
}
*/

class CTrailingParams {
public:
   int trailingstop_ticks;
   CTrailingParams(int trailingstop_ticks) : trailingstop_ticks(trailingstop_ticks) {}
};

bool calc_trailing(void* params, CSymbol* sym, double in_profit, double sl, double& newsl) {
   double ts = ((CTrailingParams*)params).trailingstop_ticks*sym.TickSize();
   if (in_profit >= ts) {
      if (-sl <= in_profit-ts) {
         newsl = -(in_profit-ts);
         return true;
      }
   }
   return false;
}

CSymbol* _symbol;
CStop* slcalc;
CStop* tpcalc;
CStop* entrycalc;
CMoneyManagement* mm;
CTrailingParams* ts;

int OnInit()
{

   _symbol = GetSymbol(NULL);
   
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
   ts = new CTrailingParams(ConvertParamToFractional(_symbol,trailingstop));

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
   CIteratorObj<CPositionDetails>* position_iter = get_positions_iterator();
   while(position_iter.HasNext()) {
      CPositionDetails* pos = position_iter.GetNext();
      addcommentln("open position: ",pos.GetId());
      TrailingSL(ts,_symbol,pos,calc_trailing);
   }
}


CIteratorObj<CPositionDetails>* get_positions_iterator() {
   CRequestSelectPositions req;
   req.filter_by_symbol = true;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_MARKET;
   ProcessOrder(ORDER_REQUEST_SELECT_POSITIONS,GetPointer(req));
   return req.iterator;
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
   CRequestCntOrders req;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_LONG;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
}

int cnt_sell() {
   CRequestCntOrders req;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_SHORT;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
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
   CRequestOpenMarketWithStops req;
   req.symbol = _symbol;
   req.magic = magic;
   req.mm = mm;
   req.order_type = ORDER_TYPE_BUY;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);  
}

void _open_sell_market() {
   CRequestOpenMarketWithStops req;
   req.symbol = _symbol;
   req.magic = magic;
   req.mm = mm;
   req.order_type = ORDER_TYPE_SELL;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);
}

void _open_buy_pending() {
   CRequestOpenPendingWithStops req;
   req.symbol = _symbol;
   req.magic = magic;
   req.mm = mm;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: req.order_type = ORDER_TYPE_BUY_LIMIT; break;
      case ENTRY_STOP: req.order_type = ORDER_TYPE_BUY_STOP; break;
   }
   req.entrycalc = entrycalc;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
   ProcessOrder(ORDER_REQUEST_OPEN_PENDING,GetPointer(req));
   Print("return ticket: ",req.ticket);  
}

void _open_sell_pending() {
   CRequestOpenPendingWithStops req;
   req.symbol = _symbol;
   req.magic = magic;
   req.mm = mm;
   switch(pending_entry_type) {
      case ENTRY_LIMIT: req.order_type = ORDER_TYPE_SELL_LIMIT; break;
      case ENTRY_STOP: req.order_type = ORDER_TYPE_SELL_STOP; break;
   }
   req.entrycalc = entrycalc;
   req.slcalc = slcalc;
   req.tpcalc = tpcalc;
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
   req.magic = magic;
   req.filter = ORDER_FILTER_LONG;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void close_sell() {
   CRequestCloseAll req;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_SHORT;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void cancel_long() {
   CRequestCancelAll req;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_LONG;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CANCEL_ALL,GetPointer(req));
}

void cancel_short() {
   CRequestCancelAll req;
   req.symbol = _symbol;
   req.magic = magic;
   req.filter = ORDER_FILTER_SHORT;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CANCEL_ALL,GetPointer(req));
}

void OnTimer()
{

}
