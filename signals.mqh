//+------------------------------------------------------------------+
//|                                                      signals.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

enum ENUM_SIGNAL {
   SIGNAL_NONE,
   SIGNAL_BOTH,
   SIGNAL_NO,
   SIGNAL_BUY,
   SIGNAL_SELL
};

typedef int (*SignalFunc)(int);

class CSignal {
public:
   virtual int Run(int bar) { return 0; }
   int operator[](int bar) { return this.Run(bar); }
   CSignal* operator&&(CSignal* other);
   CSignal* operator&&(CSignal& other);
   CSignal* operator||(CSignal* other);
   CSignal* operator||(CSignal& other);
};

class CSignalFunc : public CSignal {
protected:
   SignalFunc m_func;
public:
   CSignalFunc(SignalFunc func) : m_func(func) {}
   virtual int Run(int bar) { return m_func(bar); } 
};

CSignal* CreateSignal(SignalFunc func) {
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

class CSignalAND : public CSignal {
protected:
   CSignal* m_one;
   CSignal* m_other;
public:
   CSignalAND(CSignal* one, CSignal* other) : m_one(one), m_other(other) {}
   ~CSignalAND() {
      if (CheckPointer(m_one)==POINTER_DYNAMIC) delete m_one;
      if (CheckPointer(m_other)==POINTER_DYNAMIC) delete m_other;
   }
   virtual int Run(int bar) {
      return SignalAND(m_one.Run(bar),m_other.Run(bar));
   }
};

class CSignalOR : public CSignal {
protected:
   CSignal* m_one;
   CSignal* m_other;
public:
   CSignalOR(CSignal* one, CSignal* other) : m_one(one), m_other(other) {}
   ~CSignalOR() {
      if (CheckPointer(m_one)==POINTER_DYNAMIC) delete m_one;
      if (CheckPointer(m_other)==POINTER_DYNAMIC) delete m_other;
   }
   virtual int Run(int bar) {
      return SignalOR(m_one.Run(bar),m_other.Run(bar));
   }
};

CSignal* CSignal::operator&&(CSignal* other) {
   return new CSignalAND(GetPointer(this),other);
}

CSignal* CSignal::operator&&(CSignal& other) {
   return new CSignalAND(GetPointer(this),GetPointer(other));
}

CSignal* CSignal::operator||(CSignal* other) {
   return new CSignalOR(GetPointer(this),other);
}

CSignal* CSignal::operator||(CSignal& other) {
   return new CSignalOR(GetPointer(this),GetPointer(other));
}

typedef int (*FilterFunc)(int,CSignal*);

class CFilter {
public:
   virtual int Apply(int bar, CSignal* next) {
      return next.Run(bar);
   }
   CFilter* operator+(CFilter* other);
   CFilter* operator+=(CFilter* other);
   CSignal* operator&&(CSignal* next);
};

class CFilterFunc : public CFilter {
protected:
   FilterFunc m_func;
public:
   CFilterFunc(FilterFunc func): m_func(func) {}
   virtual int Apply(int bar, CSignal* next) {
      return m_func(bar,next);
   }
};

CFilter* CreateFilter(FilterFunc func) {
   return new CFilterFunc(func);
}

class CFilterSignal : public CSignal {
protected:
   CFilter* m_filter;
   CSignal* m_next;
   bool m_delete_pointers;
public:
   CFilterSignal(CFilter* filter, CSignal* next, bool delete_poitners = true) : m_filter(filter), m_next(next), m_delete_pointers(delete_poitners) {}
   ~CFilterSignal() {
      if (m_delete_pointers) {
         if (CheckPointer(m_filter) == POINTER_DYNAMIC) delete m_filter;
         if (CheckPointer(m_next) == POINTER_DYNAMIC) delete m_next;
      }
   }  
   virtual int Run(int bar) {
      return m_filter.Apply(bar,m_next);
   }
};

class CFilterCombined : public CFilter {
protected:
   CFilter* m_one;
   CFilter* m_other;
public:
   CFilterCombined(CFilter* one, CFilter* other) : m_one(one), m_other(other) {
      
   }
   ~CFilterCombined() {
      if (CheckPointer(m_one) == POINTER_DYNAMIC) delete m_one;
      if (CheckPointer(m_other) == POINTER_DYNAMIC) delete m_other;
   }
   virtual int Apply(int bar, CSignal* next) {
      CFilterSignal signal_other_plus_next(m_other,next,false);
      return m_one.Apply(bar,GetPointer(signal_other_plus_next));
   }
};

CFilter* CFilter::operator+(CFilter* other) {
   return new CFilterCombined(GetPointer(this),other);
}

CSignal* CFilter::operator&&(CSignal* next) {
   return new CFilterSignal(GetPointer(this),next);
}

