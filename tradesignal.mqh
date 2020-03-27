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
   TRADESIGNAL_NONE,
   TRADESIGNAL_BOTH,
   TRADESIGNAL_NO,
   SIGNAL_BUY,
   SIGNAL_SELL
};

string SignalToString(int signal) {
   switch(signal) {
      case SIGNAL_BOTH:
         return "Both";
      case SIGNAL_NO:
         return "No Signal";
      case SIGNAL_BUY:
         return "Buy";
      case SIGNAL_SELL:
         return "Sell";
      default:
         return "None";
   }
}

typedef int (*SignalFunc)(int);

class CSignalFunc : public CSignal<int,int> {
protected:
   SignalFunc m_func;
public:
   CSignalFunc(SignalFunc func) : m_func(func) {}
   virtual int Run(int bar) { return m_func(bar); } 
};

CSignal<int,int>* CreateSignal(SignalFunc func) {
   return new CSignalFunc(func);
}

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

CSignal<int,int>* signal_and(CSignal<int,int>* one, CSignal<int,int>* other) {
   return new CTradeSignalAND(one,other);
}

CSignal<int,int>* signal_or(CSignal<int,int>* one, CSignal<int,int>* other) {
   return new CTradeSignalOR(one,other);
}
