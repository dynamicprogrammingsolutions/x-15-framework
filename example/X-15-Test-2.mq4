//+------------------------------------------------------------------+
//|                                                    X-15-Test.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <x-15-0.1\main.mqh>
#include <x-15-0.1\signals.mqh>
#include <x-15-0.1\tradesignal.mqh>
#include <x-15-0.1\orders\market_orders.mqh>
#include <x-15-0.1\orders\close_orders.mqh>
#include <x-15-0.1\orders\cnt_orders.mqh>

input double lotsize = 0.1;
input int stoploss = 20;
input int takeprofit = 20;

string symbol = NULL;

int stoploss_ticks;
int takeprofit_ticks;

input int magic = 1;

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

class CTradeOnlySignalChangeState {
public:
   int lastsignal;
   CTradeOnlySignalChangeState(): lastsignal(SIGNAL_NONE) {}
};

int filter_trade_only_signal_change(int bar, CSignal<int,int>* next, void*& _state) {
   if (_state == NULL) {
      _state = new CTradeOnlySignalChangeState();
   }
   CTradeOnlySignalChangeState* state = _state;
   int signal = next.Run(bar);
   if (signal == SIGNAL_NONE) return signal;
   if (signal == state.lastsignal) {
      state.lastsignal = signal;
      return SIGNAL_NO;
   } else {
      state.lastsignal = signal;
      return signal;
   }
}

int tickcnt = 0;
datetime lastcandletime = 0;
void count_tick() {
   if (Time[0] != lastcandletime) {
      lastcandletime = Time[0];
      tickcnt = 0;
   }
   tickcnt++;
}

bool isfirsttick() {
   return tickcnt == 1;
}

int filter_trade_only_firsttick(int bar, CSignal<int,int>* next) {
   if (isfirsttick()) {
      return next.Run(bar);
   } else {
      return SIGNAL_NONE;
   }
}

CSignal<int,int>* signal_with_filters;

int get_signal() {
   return signal_with_filters.Run(1);
}

CSignal<int,int> signalxx;

class CSignalData {
public:
   datetime lastrun;
   bool did_run;
   int signal;
   int last_execution_type;
   string signal_name;
   CSignalData(string in_signal_name): signal_name(in_signal_name) {}
};

class CTradeSignalWrapperSaveData : public CTradeSignalWithStateWrapper {
public:
   CTradeSignalWrapperSaveData(CTradeSignal* delegate, string signal_name) : CTradeSignalWithStateWrapper(new CTradeSignalWithState(delegate)) {
      this.SetState(new CSignalData(signal_name));
   }
   virtual int Run(int bar) {
      CSignalData* state = this.GetState();
      state.last_execution_type = SIGNAL_EXECUTION_RUN;
      state.did_run = true;
      state.signal = m_delegate.Run(bar);
      state.lastrun = TimeCurrent();
      return state.signal;   
   }
   virtual void OnTick() {
      CSignalData* state = this.GetState();
      if (state.last_execution_type == SIGNAL_EXECUTION_ONTICK) state.did_run = false;
      state.last_execution_type = SIGNAL_EXECUTION_ONTICK;
      m_delegate.OnTick();
   }
};

class CTradeSignalWrapperWriteData : public CTradeSignalWithStateWrapper {
public:
   CTradeSignalWrapperWriteData(CTradeSignalWithState* delegate) : CTradeSignalWithStateWrapper(delegate) {}
   virtual void OnTick() {
      CSignalData* state = this.GetState();
      //Print("OnTick: signal name:",state.signal_name);
      m_delegate.OnTick();
   }
};

CTradeSignal* WrapSignal(CTradeSignal* signal, string name) {
   return new CTradeSignalWrapperWriteData(new CTradeSignalWrapperSaveData(signal,name)); 
}

class CTestObject {
public:
   int refcnt;
};

int OnInit()
{

   RegisterOrderProcessor(OrderProcessorOpenMarket);
   RegisterOrderProcessor(OrderProcessorCloseAll);
   RegisterOrderProcessor(OrderProcessorCntOrders);

   /*CSignal<int,int>* main_signal = CreateSignal(signal_candle_color) && CreateSignal(signal_macd);
   CFilter<int,int>* filters_combined = CreateFilter(filter_trade_only_firsttick);
   filters_combined += CreateFilter(filter_trade_only_signal_change);
   signal_with_filters = filters_combined && main_signal;*/   
   
   signal_with_filters = WrapSignal(CreateSignal(signal_candle_color),"Candle Color") && WrapSignal(CreateSignal(signal_macd),"MACD");
   signal_with_filters = signal_with_filters + CreateFilter(filter_trade_only_firsttick);
   signal_with_filters = signal_with_filters + CreateFilter(filter_trade_only_signal_change);

   stoploss_ticks = (int)ConvertParamToFractional(NULL,stoploss);
   takeprofit_ticks = (int)ConvertParamToFractional(NULL,takeprofit);
   
   ulong start = GetMicrosecondCount();
   Print("id NULL: ",GetSymbolId(NULL));
   Print("id NULL: ",GetSymbolId(NULL));
   Print("id _Symbol: ",GetSymbolId(_Symbol));
   Print("id _Symbol: ",GetSymbolId(_Symbol));
   Print("id GBPJPY: ",GetSymbolId("GBPJPY"));
   Print("id GBPJPY: ",GetSymbolId("GBPJPY"));
   ulong end = GetMicrosecondCount();
   Print("diff: ",end-start);
   
   start = GetMicrosecondCount();
   for(int i = 0; i < 1000; i++) {
      ticksize(NULL);
   }
   end = GetMicrosecondCount();
   Print("Benchmark 1: ",end-start);
   
   start = GetMicrosecondCount();
   for(int i = 0; i < 1000; i++) {
      ticksize(_Symbol);
   }
   end = GetMicrosecondCount();
   Print("Benchmark 2: ",end-start);
   
   start = GetMicrosecondCount();
   for(int i = 0; i < 1000; i++) {
      int id = GetSymbolId(NULL);
      ticksize_i(id);
   }
   end = GetMicrosecondCount();
   Print("Benchmark 3: ",end-start);
   
   {
   int id = GetSymbolId(NULL);
   start = GetMicrosecondCount();
   for(int i = 0; i < 1000; i++) {
      ticksize_i(id);
   }
   end = GetMicrosecondCount();
   Print("Benchmark 4: ",end-start);
   }

   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete signal_with_filters;
   
   EventKillTimer();
   
   DeregisterOrderProcessors();
   
}


void OnTick()
{
   count_tick();
   ENUM_SIGNAL signal = (ENUM_SIGNAL)get_signal();

   switch(signal) {
      case SIGNAL_BUY:
         Print("New Signal: Buy");
         process_buy();
         break;
      case SIGNAL_SELL:
         Print("New Signal: Sell");
         process_sell();
         break;
   }
   
   signal_with_filters.OnTick();
}


void process_buy() {
   close_sell();
   if (cnt_buy() > 0) return;
   open_buy();
}

void process_sell() {
   close_buy();
   if (cnt_sell() > 0) return;
   open_sell();
}

int cnt_buy() {
   CRequestCntOrders req;
   req.symbol = symbol;
   req.filter = ORDER_FILTER_LONG;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
}

int cnt_sell() {
   CRequestCntOrders req;
   req.symbol = symbol;
   req.filter = ORDER_FILTER_SHORT;
   ProcessOrder(ORDER_REQUEST_CNT_ORDERS,GetPointer(req));
   return req.cnt;
}

void open_buy() {
   CRequestOpenMarket req;
   req.symbol = symbol;
   req.volume = LotRound(req.symbol,lotsize);
   req.order_type = ORDER_TYPE_BUY;
   req.sl = AddToLoss(req.order_type,GetPrice(req.symbol,req.order_type),stoploss_ticks*ticksize(req.symbol));
   req.tp = AddToProfit(req.order_type,GetPrice(req.symbol,req.order_type),takeprofit_ticks*ticksize(req.symbol));
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);  
}


void open_sell() {
   CRequestOpenMarket req;
   req.symbol = symbol;
   req.volume = LotRound(req.symbol,lotsize);
   req.order_type = ORDER_TYPE_SELL;
   req.sl = AddToLoss(req.order_type,GetPrice(req.symbol,req.order_type),stoploss_ticks*ticksize(req.symbol));
   req.tp = AddToProfit(req.order_type,GetPrice(req.symbol,req.order_type),takeprofit_ticks*ticksize(req.symbol));
   ProcessOrder(ORDER_REQUEST_OPEN_MARKET,GetPointer(req));
   Print("return ticket: ",req.ticket);
}

void close_callback(int order_ticket, bool success, int error) {
   if (!success) {
      Print("close error: ",ErrorDescription(error));
   }
}

void close_buy() {
   CRequestCloseAll req;
   req.symbol = symbol;
   req.filter = ORDER_FILTER_LONG;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void close_sell() {
   CRequestCloseAll req;
   req.symbol = symbol;
   req.filter = ORDER_FILTER_SHORT;
   req.callback = close_callback;
   ProcessOrder(ORDER_REQUEST_CLOSE_ALL,GetPointer(req));
}

void OnTimer()
{

}
