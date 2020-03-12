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
#include <x-15-0.1\orders.mqh>

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

int OnInit()
{
   /*CSignal<int,int>* main_signal = CreateSignal(signal_candle_color) && CreateSignal(signal_macd);
   CFilter<int,int>* filters_combined = CreateFilter(filter_trade_only_firsttick);
   filters_combined += CreateFilter(filter_trade_only_signal_change);
   signal_with_filters = filters_combined && main_signal;*/   
   
   signal_with_filters = WrapSignal(CreateSignal(signal_candle_color),"Candle Color") && WrapSignal(CreateSignal(signal_macd),"MACD");
   signal_with_filters = signal_with_filters + CreateFilter(filter_trade_only_firsttick);
   signal_with_filters = signal_with_filters + CreateFilter(filter_trade_only_signal_change);

   EventSetTimer(60);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete signal_with_filters;
   
   EventKillTimer();
   
}


typedef void (*ActionCallback)(void* action);

enum ENUM_ACTION_TYPE {
   ACTION_NONE,
   ACTION_CLOSEBUY,
   ACTION_CLOSESELL,
   ACTION_CLOSEALL,
   ACTION_BUY,
   ACTION_SELL
};

class CAction {
   ENUM_ACTION_TYPE m_type;
public:
   CAction(): m_type(ACTION_NONE) {}
   CAction(ENUM_ACTION_TYPE type): m_type(type) {}
   CAction(CAction& other): m_type(other.m_type) {}
   ENUM_ACTION_TYPE GetType() {
      return m_type;
   }
};

void process_action(void* _action) {
   CAction* action = _action;
   Print(EnumToString(action.GetType()));
   switch(action.GetType()) {
      case ACTION_BUY:
         
         break;
      case ACTION_SELL:
         break;
      case ACTION_CLOSEBUY:
         break;
      case ACTION_CLOSESELL:
         break;
      case ACTION_CLOSEALL:
         break;
   }
}

void process_signal(ENUM_SIGNAL signal, ActionCallback action_callback) {
   CAction action;
   switch(signal) {
      case SIGNAL_NO:
         break;
      case SIGNAL_BUY:
         action = CAction(ACTION_CLOSESELL);
         action_callback(GetPointer(action));
         action = CAction(ACTION_BUY);
         action_callback(GetPointer(action));
         break;
      case SIGNAL_SELL:
         action = CAction(ACTION_CLOSEBUY);
         action_callback(GetPointer(action));
         action = CAction(ACTION_SELL);
         action_callback(GetPointer(action));
         
         break;
   }
}

void OnTick()
{
   count_tick();
   ENUM_SIGNAL signal = (ENUM_SIGNAL)get_signal();
   process_signal(signal,process_action);
   
   signal_with_filters.OnTick();
}

void OnTimer()
{

   
}
