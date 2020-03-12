//+------------------------------------------------------------------+
//|                                                       orders.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

class COrderProcessor {
public:
   virtual void ProcessOrder(int request, void* parameters, COrderProcessor* next) {
      
   }
   virtual void ProcessOrder(int request, void* parameters) {
      
   }
};

class COrderProcessorNull : public COrderProcessor {
public:
   virtual void ProcessOrder(int request, void* parameters) {
      
   }
};

typedef void (*OrderProcessorFunc)(int request, void* parameters, COrderProcessor* next);

class COrderProcessorFunc : public COrderProcessor{
   OrderProcessorFunc m_func;
public:
   COrderProcessorFunc(OrderProcessorFunc func) : m_func(func) {}
   virtual void ProcessOrder(int request, void* parameters, COrderProcessor* next) {
      m_func(request, parameters, next);
   }
};

class COrderProcessorWithNext : public COrderProcessor {
   COrderProcessor* m_delegate;
   COrderProcessor* m_next;
public:
   COrderProcessorWithNext(COrderProcessor* delegate, COrderProcessor* next): m_delegate(delegate), m_next(next) {}
   virtual void ProcessOrder(int request, void* parameters) {
      m_delegate.ProcessOrder(request, parameters, m_next);
   }
};

class COrderProcessorWithoutNext : public COrderProcessor {
   COrderProcessor* m_delegate;
   COrderProcessorNull m_next;
public:
   COrderProcessorWithoutNext(COrderProcessor* delegate): m_delegate(delegate) {}
   virtual void ProcessOrder(int request, void* parameters) {
      m_delegate.ProcessOrder(request,parameters,GetPointer(m_next));
   }
};


class __COrderProcessorChain {
   COrderProcessor* m_order_processor;
public:
   void AddOrderProcessor(COrderProcessor* order_processor) {
      if (CheckPointer(m_order_processor) == POINTER_INVALID) {
         m_order_processor = new COrderProcessorWithoutNext(order_processor);
      } else {
         m_order_processor = new COrderProcessorWithNext(order_processor,m_order_processor);
      }
   }
   bool OrderProcessorRegistered() {
      return CheckPointer(m_order_processor) != POINTER_INVALID;
   }
   void RemoveOrderProcessors() {
      if (CheckPointer(m_order_processor) == POINTER_DYNAMIC) delete m_order_processor;
      m_order_processor = NULL;
   }
   void ProcessOrder(int request, void* parameters) {
      if (m_order_processor) {
         m_order_processor.ProcessOrder(request,parameters);
      }
   }
} __OrderProcessorChain;


void RegisterOrderProcessor(OrderProcessorFunc orderProcessorFunc) {
   __OrderProcessorChain.AddOrderProcessor(new COrderProcessorFunc(orderProcessorFunc));
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
