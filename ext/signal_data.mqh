//+------------------------------------------------------------------+
//|                                                  signal_data.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "../signals.mqh"
#include "../tradesignal.mqh"

#define SIGNAL_EXECUTION_RUN 1
#define SIGNAL_EXECUTION_ONTICK 2

class CSignalData {
public:
   datetime lastrun;
   bool did_run;
   int signal;
   int last_execution_type;
   string signal_name;
   CSignalData(string in_signal_name): signal_name(in_signal_name) {}
};

class CWrapperSaveData : public CSignalWithStateWrapper<int,int> {
public:
   CWrapperSaveData(CSignal<int,int>* delegate, string signal_name) : CSignalWithStateWrapper<int,int>(new CSignalWithState<int,int>(delegate)) {
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

typedef void (*SignalDataWriterFunc)(CSignalData*);

class CWrapperWriteData : public CSignalWithStateWrapper<int,int> {
   SignalDataWriterFunc m_func;
public:
   CWrapperWriteData(CSignalWithState<int,int>* delegate, SignalDataWriterFunc func) : CSignalWithStateWrapper<int,int>(delegate), m_func(func) {}
   virtual void OnTick() {
      CSignalData* state = this.GetState();
      m_func(state);
      m_delegate.OnTick();
   }
};

