#property strict

#include "..\order_processor_register.mqh"
#include "..\share\orderselect_shared_filters.mqh"
#include "request_select_orders.mqh"

#ifdef __MQL4__

#include "..\share\mt4\pending_order_details_impl.mqh"

   /*
      TODO: In next version do this architecture:
         1. pass a pointer of CSelectOrdersIterator to the request
         2. The processor stores the idx and total in the passed CSelectOrdersIterator
         3. The processor will put a delegate object in the passed CSelectOrdersIterator.
            The delegate object will be static and will not contain any state, so it can be reused. It's task will be to process the
            HasNext and GetNext based on details stored int the iterator.
   */

   class CSelectOrdersIterator : public CIteratorObj<CPendingOrderDetails> {
      int m_total;
      int idx;
      CRequestSelectOrders req;
      CPendingOrderDetailsImpl details;
   public:
      CSelectOrdersIterator() {}
      CSelectOrdersIterator(int total, CRequestSelectOrders* _req): m_total(total), req(_req) {
         idx = total-1;
         m_total = total;
      }
      CSelectOrdersIterator(CSelectOrdersIterator* other): m_total(other.m_total), req(other.req) {}
      CSelectOrdersIterator(CSelectOrdersIterator& other): m_total(other.m_total), req(other.req) {}
      virtual CPendingOrderDetails* GetNext() {
         return GetPointer(details);
      }
      virtual bool HasNext() {
         if (idx < 0) return false;
         for (int i = idx; i >= 0; i--) {
            if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
               if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                     && (!req.filter_by_magic || __FilterByMagicNumber(OrderMagicNumber(),req.magic))
                     && FilterOrder(OrderType(),ORDER_FILTER_PENDING & req.filter))
               {
                  idx = i-1;
                  return true;
               }
            }
         }
         idx = -1;
         return false;
      }
   };
   
   CSelectOrdersIterator __static_CSelectOrdersIterator;

   void SelectOrders(CRequestSelectOrders* req) {
      if (req.callback != NULL || req.count_only) {
         int total = OrdersTotal();
         req.cnt = 0;
         for (int i = total-1; i >= 0; i--) {
            if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
               if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                     && (!req.filter_by_magic || __FilterByMagicNumber(OrderMagicNumber(),req.magic))
                     && FilterOrder(OrderType(),ORDER_FILTER_PENDING & req.filter))
               {
                  if (req.callback != NULL) {
                     CPendingOrderDetailsImpl details;
                     req.callback(GetPointer(details),req.callback_obj);
                  }
                  req.cnt++;
               }
            }
         }
      } else {
         __static_CSelectOrdersIterator = CSelectOrdersIterator(OrdersTotal(),req);
         req.iterator = GetPointer(__static_CSelectOrdersIterator);
      }
   }
#endif
#ifdef __MQL5__
   void SelectOrders(CRequestSelectOrders* req) {
      
   }
#endif

void OrderProcessorSelectOrders(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_SELECT_ORDERS) {
      CRequestSelectOrders* req = parameters;
      SelectOrders(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}