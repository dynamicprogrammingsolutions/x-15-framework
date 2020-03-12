//+------------------------------------------------------------------+
//|                                                  tradesignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "signals.mqh"

enum ENUM_SIGNAL {
   SIGNAL_NONE,
   SIGNAL_BOTH,
   SIGNAL_NO,
   SIGNAL_BUY,
   SIGNAL_SELL
};

typedef int (*SignalFunc)(int);

class CTradeSignal : public CSignal<int,int> {
public:
   virtual CSignal<int,int>* getANDCombinator(CSignal<int,int>* one, CSignal<int,int>* other) {
      return new CTradeSignalWrapper(new CTradeSignalAND(one,other));
   }
   virtual CSignal<int,int>* getORCombinator(CSignal<int,int>* one, CSignal<int,int>* other) {
      return new CTradeSignalWrapper(new CTradeSignalOR(one,other));
   }
};

class CTradeSignalWrapper : public CTradeSignal {
private:
   CSignal<int,int>* m_delegate;
public:
   CTradeSignalWrapper(CSignal<int,int>* delegate) : m_delegate(delegate) {}
   ~CTradeSignalWrapper() {
      if (CheckPointer(m_delegate)==POINTER_DYNAMIC) delete m_delegate;
   }
   virtual int Run(int bar) {
      return m_delegate.Run(bar);
   }
   virtual void OnTick() {
      m_delegate.OnTick();
   }
};

typedef int (*TradeSignalSaverFunc)(int,CTradeSignal*,int,void*&);
typedef int (*TradeSignalWrapperFunc)(int,CTradeSignal*,int,void*);
#define SIGNAL_EXECUTION_RUN 1
#define SIGNAL_EXECUTION_ONTICK 2

class CTradeSignalWithState : public CTradeSignal {
private:
   void* m_state;
protected:
   CTradeSignal* m_delegate;
public:
   CTradeSignalWithState(CTradeSignal* delegate) : m_delegate(delegate) {}
   ~CTradeSignalWithState() {
      if (CheckPointer(m_state)==POINTER_DYNAMIC) delete m_state;
   }
   virtual int Run(int bar) {
      return m_delegate.Run(bar);
   }
   virtual void OnTick() {
      m_delegate.OnTick();
   }
   virtual void SetState(void* state) { m_state = state; }
   virtual void* GetState() { return m_state; }
};

class CTradeSignalWithStateWrapper : public CTradeSignalWithState {
public:
   CTradeSignalWithStateWrapper(CTradeSignalWithState* delegate) : CTradeSignalWithState(delegate) {}
   virtual void SetState(void* state) { ((CTradeSignalWithState*)m_delegate).SetState(state); }
   virtual void* GetState() { return ((CTradeSignalWithState*)m_delegate).GetState(); }
};

class CSignalFunc : public CTradeSignal {
protected:
   SignalFunc m_func;
public:
   CSignalFunc(SignalFunc func) : m_func(func) {}
   virtual int Run(int bar) { return m_func(bar); } 
};

CSignal<int,int>* CreateSignal(SignalFunc func) {
   return new CSignalFunc(func);
}

int SignalAND(int one, int other) {
   if (one == other) return one;
   if (one == 0) return other;
   if (other == 0) return one;
   if (one == 1) {
      if (other > 1) return other;
      else return one;
   }
   if (other == 1) {
      if (one > 1) return one;
      else return other;
   }
   return 2;
}

int SignalOR(int one, int other) {
   if (one == 0) return other;
   if (other == 0) return one;
   if (one == 1 || other == 1) return 1;
   if (one == 2) {
      if (other > 2) return other;
      else return one;
   }
   if (other == 2) {
      if (one > 2) return one;
      else return other;
   }
   // if (one > 2 && other > 2) 
   return 1;
}

class CTradeSignalAND : public CSignalCombinator<int,int> {
public:
   CTradeSignalAND(CSignal<int,int>* left, CSignal<int,int>* right, bool delete_pointers = true) : CSignalCombinator(left,right,delete_pointers) {}
   virtual int Combine(int left, int right) {
      return SignalAND(left, right);
   }
};

class CTradeSignalOR : public CSignalCombinator<int,int> {
public:
   CTradeSignalOR(CSignal<int,int>* left, CSignal<int,int>* right, bool delete_pointers = true) : CSignalCombinator(left,right,delete_pointers) {}
   virtual int Combine(int left, int right) {
      return SignalOR(left, right);
   }
};



/*
class CTradeSignalAND : public CTradeSignal {
protected:
   CSignal<int,int>* m_one;
   CSignal<int,int>* m_other;
   bool m_delete_pointers;
public:
   CTradeSignalAND(CSignal<int,int>* one, CSignal<int,int>* other, bool delete_pointers=true) :
      m_one(one),
      m_other(other),
      m_delete_pointers(delete_pointers)
      {}
   ~CTradeSignalAND() {
      if (m_delete_pointers) {
         if (CheckPointer(m_one)==POINTER_DYNAMIC) delete m_one;
         if (CheckPointer(m_other)==POINTER_DYNAMIC) delete m_other;
      }
   }
   virtual int Run(int bar) {
      return SignalAND(m_one.Run(bar),m_other.Run(bar));
   }
   virtual void OnTick() {
      m_one.OnTick();
      m_other.OnTick();
   }
};

class CTradeSignalOR : public CTradeSignal {
protected:
   CSignal<int,int>* m_one;
   CSignal<int,int>* m_other;
   bool m_delete_pointers;
public:
   CTradeSignalOR(CSignal<int,int>* one, CSignal<int,int>* other, bool delete_pointers = true) : 
      m_one(one),
      m_other(other),
      m_delete_pointers(delete_pointers)
      {}
   ~CTradeSignalOR() {
      if (m_delete_pointers) {
         if (CheckPointer(m_one)==POINTER_DYNAMIC) delete m_one;
         if (CheckPointer(m_other)==POINTER_DYNAMIC) delete m_other;
      }
   }
   virtual int Run(int bar) {
      return SignalOR(m_one.Run(bar),m_other.Run(bar));
   }
   virtual void OnTick() {
      m_one.OnTick();
      m_other.OnTick();
   }
};
*/

typedef int (*FilterFunc)(int,CSignal<int,int>*);
typedef int (*FilterFuncWithState)(int,CSignal<int,int>*,void*&);

class CFilterFunc : public CFilter<int,int> {
protected:
   FilterFunc m_func;
public:
   CFilterFunc(FilterFunc func): m_func(func) {}
   virtual int Apply(int bar, CSignal<int,int>* next) {
      return m_func(bar,next);
   }
};

CFilter<int,int>* CreateFilter(FilterFunc func) {
   return new CFilterFunc(func);
}

class CFilterFuncWithState : public CFilter<int,int> {
protected:
   FilterFuncWithState m_func;
   void* m_state;
public:
   CFilterFuncWithState(FilterFuncWithState func): m_func(func) {}
   ~CFilterFuncWithState() {
      if (CheckPointer(m_state)==POINTER_DYNAMIC) delete m_state;
   }
   virtual int Apply(int bar, CSignal<int,int>* next) {
      return m_func(bar,next,m_state);
   }
};

CFilter<int,int>* CreateFilter(FilterFuncWithState func) {
   return new CFilterFuncWithState(func);
}