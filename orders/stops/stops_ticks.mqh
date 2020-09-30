#property strict

#include "stops.mqh"

#include "../share/request_order.mqh"
#include "../modify_pending_order/modify_pending_order.mqh"
#include "../modify_position/modify_position.mqh"

class CStopTicks : public CStop {
   int m_ticks;
public:
   CStopTicks(int ticks) : m_ticks(ticks) {}
   virtual double Calculate(CRequest* request, ENUM_STOP_MODE stopmode) {
      if (dynamic_cast<CRequestOrder*>(request) != NULL) {
         CRequestOrder* req_order = request;
         switch(stopmode) {
            case STOP_MODE_SL:
            case STOP_MODE_TP:
               if (m_ticks == 0) return 0;
               return AddToStop(stopmode,req_order.order_type,req_order.price,m_ticks*req_order.symbol.TickSize());
            case STOP_MODE_ENTRY:
               return AddToStop(stopmode,req_order.order_type,req_order.current_price,m_ticks*req_order.symbol.TickSize());
         }
         
      }
      if (dynamic_cast<CRequestModifyPending*>(request) != NULL) {
         CRequestModifyPending* req_order = request;
         switch(stopmode) {
            case STOP_MODE_SL:
            case STOP_MODE_TP:
               if (m_ticks == 0) return 0;
               return AddToStop(stopmode,(ENUM_ORDER_TYPE)req_order.order_details.GetOrderType(),req_order.price,m_ticks*req_order.symbol.TickSize());
            case STOP_MODE_ENTRY:
               return AddToStop(stopmode,(ENUM_ORDER_TYPE)req_order.order_details.GetOrderType(),req_order.current_price,m_ticks*req_order.symbol.TickSize());
         }
         
      }
       if (dynamic_cast<CRequestModifyPosition*>(request) != NULL) {
         CRequestModifyPosition* req_order = request;
         switch(stopmode) {
            case STOP_MODE_SL:
            case STOP_MODE_TP:
               if (m_ticks == 0) return 0;
               return AddToStop(stopmode,(ENUM_ORDER_TYPE)req_order.position_details.GetPositionType(),req_order.position_details.GetEntryPrice(),m_ticks*req_order.symbol.TickSize());
            case STOP_MODE_ENTRY:
               return -1;
         }
         
      }
      return -1;
   }
};