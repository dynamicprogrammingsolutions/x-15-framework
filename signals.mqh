//+------------------------------------------------------------------+
//|                                                      signals.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "ptr.mqh"

#define SIGNAL_NONE 0
#define SIGNAL_BOTH 1
#define SIGNAL_NO 2

template<typename I,typename O>
class CSignal {
public:
   int refcnt;
   virtual O Run(I bar) { return NULL; }
   virtual void OnTick() {}
   O operator[](I bar) { return this.Run(bar); }
   /*virtual CSignal<I,O>* getANDCombinator(CSignal* one, CSignal* other) { return NULL; }
   virtual CSignal<I,O>* getORCombinator(CSignal* one, CSignal* other) { return NULL; }
   CSignal<I,O>* operator&&(CSignal<I,O>* other) { return getANDCombinator(GetPointer(this),other); }
   CSignal<I,O>* operator&&(CSignal<I,O>& other) { return getANDCombinator(GetPointer(this),GetPointer(other)); }
   CSignal<I,O>* operator||(CSignal<I,O>* other) { return getORCombinator(GetPointer(this),other); }
   CSignal<I,O>* operator||(CSignal<I,O>& other) { return getORCombinator(GetPointer(this),GetPointer(other)); }
   CSignal<I,O>* operator+(CFilter<I,O>* other) { return new CFilterSignal<I,O>(other,GetPointer(this)); }*/  
};


template<typename I,typename O>
class CFilter {
public:
   int refcnt;
   virtual O Apply(I bar, CSignal<I,O>* next) {
      return next.Run(bar);
   }
   virtual void OnTick() {}
   /*CFilter<I,O>* operator+(CFilter<I,O>* other) {
      return new CFilterCombined<I,O>(GetPointer(this),other);
   }
   CSignal<I,O>* operator&&(CSignal<I,O>* next) {
      return new CFilterSignal<I,O>(GetPointer(this),next);
   }*/
};


template<typename I,typename O>
class CFilterSignal : public CSignal<I,O> {
protected:
   CFilter<I,O>* m_filter;
   CSignal<I,O>* m_next;
   bool m_delete_pointers;
public:
   CFilterSignal(CFilter<I,O>* filter, CSignal<I,O>* next, bool delete_poitners = true) :
      m_filter(filter),
      m_next(next),
      m_delete_pointers(delete_poitners)
   {
      AttachPtr(m_filter);
      AttachPtr(m_next);
   }
      
   ~CFilterSignal() {
      DetachPtr(m_filter);
      DetachPtr(m_next);
      /*if (m_delete_pointers) {
         if (CheckPointer(m_filter) == POINTER_DYNAMIC) delete m_filter;
         if (CheckPointer(m_next) == POINTER_DYNAMIC) delete m_next;
      }*/
   }  
   virtual O Run(I bar) {
      return m_filter.Apply(bar,m_next);
   }
   virtual void OnTick() {
      m_filter.OnTick();
      m_next.OnTick();
   }
};

template<typename In, typename Out>
CSignal<In,Out>* add_filter(CSignal<In,Out>* signal, CFilter<In,Out>* filter) { return new CFilterSignal<In,Out>(filter,signal); }

template<typename I,typename O>
class CFilterCombined : public CFilter<I,O> {
protected:
   CFilter<I,O>* m_one;
   CFilter<I,O>* m_other;
   bool m_delete_pointers;
public:
   CFilterCombined(CFilter<I,O>* one, CFilter<I,O>* other, bool delete_poitners = true) :
      m_one(one),
      m_other(other),
      m_delete_pointers(delete_poitners)
   {
      AttachPtr(m_one);
      AttachPtr(m_other);
   }
      
   ~CFilterCombined() {
      /*if (m_delete_pointers) {
         if (CheckPointer(m_one) == POINTER_DYNAMIC) delete m_one;
         if (CheckPointer(m_other) == POINTER_DYNAMIC) delete m_other;
      }*/
      DetachPtr(m_one);
      DetachPtr(m_other);
   }
   virtual O Apply(O bar, CSignal<I,O>* next) {
      CFilterSignal<I,O> signal_other_plus_next(m_other,next,false);
      return m_one.Apply(bar,GetPointer(signal_other_plus_next));
   }
   virtual void OnTick() {
      m_one.OnTick();
      m_other.OnTick();
   }
};

template<typename In, typename Out>
CFilter<In,Out>* combine_filters(CFilter<In,Out>* one, CFilter<In,Out>* other) {
   return new CFilterCombined<In,Out>(one,other);
}

template<typename I, typename O>
class CSignalCombinator : public CSignal<I,O> {
protected:
   CSignal<I,O>* m_left;
   CSignal<I,O>* m_right;
   bool m_delete_pointers;
public:
   CSignalCombinator(CSignal<I,O>* left, CSignal<I,O>* right, bool delete_pointers = true):
      m_left(left),
      m_right(right),
      m_delete_pointers(delete_pointers)
   {
      AttachPtr(m_left);
      AttachPtr(m_right);
   }
   ~CSignalCombinator() {
      DetachPtr(m_left);
      DetachPtr(m_right);
      /*if (m_delete_pointers) {
         if (CheckPointer(m_left) == POINTER_DYNAMIC) delete m_left;
         if (CheckPointer(m_right) == POINTER_DYNAMIC) delete m_right;
      }*/
   }
   virtual O Combine(O left, O right) {
      return NULL;
   }
   virtual O Run(I bar) {
      O leftsignal = m_left.Run(bar);
      O rightsignal = m_right.Run(bar);
      return Combine(leftsignal,rightsignal);
   }
   virtual void OnTick() {
      m_left.OnTick();
      m_right.OnTick();
   }
};

template<typename I, typename O>
class CSignalWithState : public CSignal<I,O> {
private:
   void* m_state;
protected:
   CSignal<I,O>* m_delegate;
public:
   CSignalWithState(CSignal<I,O>* delegate) : m_delegate(delegate) {
      AttachPtr(m_delegate);
   }
   ~CSignalWithState() {
      DetachPtr(m_delegate);
      if (CheckPointer(m_state)==POINTER_DYNAMIC) delete m_state;
   }
   virtual O Run(I bar) {
      return m_delegate.Run(bar);
   }
   virtual void OnTick() {
      m_delegate.OnTick();
   }
   virtual void SetState(void* state) {
      m_state = state;
   }
   virtual void* GetState() { return m_state; }
};

template<typename I, typename O>
class CSignalWithStateWrapper : public CSignalWithState<I,O> {
public:
   CSignalWithStateWrapper(CSignalWithState<I,O>* delegate) : CSignalWithState<I,O>(delegate) {}
   virtual void SetState(void* state) { ((CSignalWithState<I,O>*)m_delegate).SetState(state); }
   virtual void* GetState() { return ((CSignalWithState<I,O>*)m_delegate).GetState(); }
};