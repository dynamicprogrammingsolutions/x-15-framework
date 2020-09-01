//+------------------------------------------------------------------+
//|                                                       orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "..\ptr.mqh"
#include "..\objecttools.mqh"
#include "..\logger.mqh"

class COrderProcessor {
public:
   CLASSNAME
   int refcnt;
   virtual void ProcessOrder(int request, void* parameters, COrderProcessor* next) {
      ABSTRACT_METHOD_WARNING
   }
   virtual void ProcessOrder(int request, void* parameters) {
      ABSTRACT_METHOD_WARNING
   }
};

class COrderProcessorNull : public COrderProcessor {
public:
   CLASSNAME
   virtual void ProcessOrder(int request, void* parameters) {
   
   }
};

typedef void (*OrderProcessorFunc)(int request, void* parameters, COrderProcessor* next);

class COrderProcessorFunc : public COrderProcessor{
   OrderProcessorFunc m_func;
public:
   CLASSNAME
   COrderProcessorFunc(OrderProcessorFunc func) : m_func(func) {}
   virtual void ProcessOrder(int request, void* parameters, COrderProcessor* next) {
      m_func(request, parameters, next);
   }
};

class COrderProcessorWithNext : public COrderProcessor {
   COrderProcessor* m_delegate;
   COrderProcessor* m_next;
public:
   CLASSNAME
   COrderProcessorWithNext(COrderProcessor* delegate, COrderProcessor* next): m_delegate(delegate), m_next(next) {
      AttachPtr(m_delegate);
      AttachPtr(m_next);
   }
   ~COrderProcessorWithNext() {
      DetachPtr(m_delegate);
      DetachPtr(m_next);
   }
   virtual void ProcessOrder(int request, void* parameters) {
      m_delegate.ProcessOrder(request, parameters, m_next);
   }
};

class COrderProcessorWithoutNext : public COrderProcessor {
   COrderProcessor* m_delegate;
   COrderProcessorNull m_next;
public:
   CLASSNAME
   COrderProcessorWithoutNext(COrderProcessor* delegate): m_delegate(delegate) {
      AttachPtr(m_delegate);
   }
   ~COrderProcessorWithoutNext() {
      DetachPtr(m_delegate);
   }
   virtual void ProcessOrder(int request, void* parameters) {
      m_delegate.ProcessOrder(request,parameters,GetPointer(m_next));
   }
};

class COrderProcessorByRequestId : public COrderProcessor {
   COrderProcessor* m_order_processor_by_reqid[1024];
public:
   CLASSNAME
   ~COrderProcessorByRequestId() {
      RemoveOrderProcessors();
   }
   void AddOrderProcessor(int request, COrderProcessor* order_processor) {
      if (CheckPointer(m_order_processor_by_reqid[request]) == POINTER_INVALID) {
         m_order_processor_by_reqid[request] = AttachPtr(new COrderProcessorWithoutNext(order_processor));
      } else {
         m_order_processor_by_reqid[request] = ReplacePtr(m_order_processor_by_reqid[request],new COrderProcessorWithNext(order_processor,m_order_processor_by_reqid[request]));
      }
   }
   void RemoveOrderProcessors() {
      //TODO: create a linked list to avoid traverse 1024 items
      for (int i = 0; i < 1024; i++) {
         if (CheckPointer(m_order_processor_by_reqid[i]) != POINTER_INVALID) {
            DetachPtr(m_order_processor_by_reqid[i]);
         }
      }
   }
   void ProcessOrder(int request, void* parameters) {
      if (CheckPointer(m_order_processor_by_reqid[request]) != POINTER_INVALID) {
         m_order_processor_by_reqid[request].ProcessOrder(request,parameters);
      }
   }
};

class __COrderProcessorChain {
   COrderProcessor* m_order_processor;
   COrderProcessorByRequestId m_order_processor_by_reqid;
public:
   CLASSNAME
   ~__COrderProcessorChain() {
      DetachPtr(m_order_processor);
   }
   void AddOrderProcessor(int request, COrderProcessor* order_processor) {
      m_order_processor_by_reqid.AddOrderProcessor(request,order_processor);
      if (CheckPointer(m_order_processor) == POINTER_INVALID) {
         m_order_processor = AttachPtr(GetPointer(m_order_processor_by_reqid));
      }
   }
   void AddOrderProcessor(COrderProcessor* order_processor) {
      if (CheckPointer(m_order_processor) == POINTER_INVALID) {
         m_order_processor = AttachPtr(new COrderProcessorWithNext(order_processor,GetPointer(m_order_processor_by_reqid)));
      } else {
         m_order_processor = ReplacePtr(m_order_processor,new COrderProcessorWithNext(order_processor,m_order_processor));
      }
   }
   bool OrderProcessorRegistered() {
      return CheckPointer(m_order_processor) != POINTER_INVALID;
   }
   void RemoveOrderProcessors() {
      DetachPtr(m_order_processor);
      m_order_processor = NULL;
      m_order_processor_by_reqid.RemoveOrderProcessors();
   }
   void ProcessOrder(int request, void* parameters) {
      if (CheckPointer(m_order_processor) != POINTER_INVALID) {
         m_order_processor.ProcessOrder(request,parameters);
      } else {
         debug(("no processor"));
      }
   }
} __OrderProcessorChain;


void RegisterOrderProcessor(OrderProcessorFunc orderProcessorFunc) {
   __OrderProcessorChain.AddOrderProcessor(new COrderProcessorFunc(orderProcessorFunc));
}

void RegisterOrderProcessor(int request, OrderProcessorFunc orderProcessorFunc) {
   __OrderProcessorChain.AddOrderProcessor(request, new COrderProcessorFunc(orderProcessorFunc));
}

bool OrderProcessorRegistered() {
   return __OrderProcessorChain.OrderProcessorRegistered();
}

void DeregisterOrderProcessors(){
   __OrderProcessorChain.RemoveOrderProcessors();
}

void ProcessOrder(int request, void* parameters) {
   __OrderProcessorChain.ProcessOrder(request,parameters);
}
