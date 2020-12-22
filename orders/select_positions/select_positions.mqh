#property strict

#include "../order_processor_register.mqh"
#include "../share/orderselect_shared_filters.mqh"
#include "request_select_positions.mqh"

#ifdef __MQL4__

#include "..\share\mt4\position_details_impl.mqh"

class CSelectPositionsIterator : public CIteratorObj<CPositionDetails> {
   int m_total;
   int idx;
   CRequestSelectPositions req;
   CPositionDetailsImpl details;
public:
   CSelectPositionsIterator() {}
   CSelectPositionsIterator(int total, CRequestSelectPositions* _req): m_total(total), req(_req) {
      idx = total-1;
      m_total = total;
   }
   CSelectPositionsIterator(CSelectPositionsIterator* other): m_total(other.m_total), req(other.req) {}
   CSelectPositionsIterator(CSelectPositionsIterator& other): m_total(other.m_total), req(other.req) {}
   virtual CPositionDetails* GetNext() {
      return GetPointer(details);
   }
   virtual bool HasNext() {
      if (idx < 0) return false;
      for (int i = idx; i >= 0; i--) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
            if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                  && (!req.filter_by_magic || __FilterByMagicNumber(OrderMagicNumber(),req.magic))
                  && FilterOrder(OrderType(),ORDER_FILTER_MARKET & req.filter)
                  && (req.filter_callback == NULL || req.filter_callback(GetPointer(details))))
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
   CSelectPositionsIterator __static_CSelectPositionsIterator;

   void SelectPositions(CRequestSelectPositions* req) {
      if (req.callback != NULL || req.count_only) {
         int total = OrdersTotal();
         req.cnt = 0;
         CPositionDetailsImpl details;
         for (int i = total-1; i >= 0; i--) {
            if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
               if ((!req.filter_by_symbol || __FilterBySymbol(OrderSymbol(),req.symbol))
                     && (!req.filter_by_magic || __FilterByMagicNumber(OrderMagicNumber(),req.magic))
                     && FilterOrder(OrderType(),ORDER_FILTER_MARKET & req.filter)
                     && (req.filter_callback == NULL || req.filter_callback(GetPointer(details))))
               {
                  if (req.callback) {
                     CPositionDetailsImpl details;
                     req.callback(GetPointer(details),req.callback_obj);
                  }
                  req.cnt++;
               }
            }
         }
      } else {
         __static_CSelectPositionsIterator = CSelectPositionsIterator(OrdersTotal(),req);
         req.iterator = GetPointer(__static_CSelectPositionsIterator);
      }
   }
#endif
#ifdef __MQL5__
   void SelectPositions(CRequestSelectPositions* req) {
      
   }
#endif

void OrderProcessorSelectPositions(int request, void* parameters, COrderProcessor* next) {
   if (request == ORDER_REQUEST_SELECT_POSITIONS) {
      CRequestSelectPositions* req = parameters;
      SelectPositions(req);
   } else {
      next.ProcessOrder(request,parameters);
   }
}