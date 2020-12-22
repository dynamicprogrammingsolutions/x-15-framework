#property strict

#include "../order_processor_register.mqh"
#include "../../logger.mqh"
#include "../order_request_codes.mqh"
#include "../market_orders/market_orders.mqh"
#include "../pending_orders/pending_orders.mqh"
#include "../get_position_details/get_position_details.mqh"
#include "../get_order_details/get_order_details.mqh"
#include "../share/position_details.mqh"
#include "../share/mt4/position_details_impl.mqh"
#include "../share/mt4/pending_order_details_impl.mqh"
#include "../share/pending_order_details.mqh"
#include "../close_position/request_close_position.mqh"
#include <Arrays/List.mqh>

enum ENUM_ORDER_STATUS {
   OS_PENDING,
   OS_CANCELED,
   OS_FILLED,
   OS_CLOSED
};

class COrderTracker : public CObject {
public:
   virtual ENUM_ORDER_STATUS GetStatus() { return 0; }
   virtual void SetStatus(ENUM_ORDER_STATUS newstatus) {};
   virtual long GetId() { return -1; }
   virtual bool CanDelete() { return false; }
   virtual void ModifyId(long new_id) {}
   virtual void ManageHistory() { Print("Abstract function: ",__FUNCTION__); }
   virtual void ManageHistory(CPositionDetails* pos) { Print("Abstract function: ",__FUNCTION__); }
   virtual void Manage(CPositionDetails* pos) { Print("Abstract function: ",__FUNCTION__); }
   virtual void Manage(CPendingOrderDetails* pos) { Print("Abstract function: ",__FUNCTION__); }
};

class COrderTrackerDefault : public COrderTracker {
protected:
   long m_id;
   bool m_can_delete;
public:
   COrderTrackerDefault(CPositionDetails* pos): m_id(pos.GetId()) {}
   COrderTrackerDefault(CPendingOrderDetails* order): m_id(order.GetId()) {}
   virtual long GetId() { return m_id; }
   virtual bool CanDelete() { return m_can_delete; }
   virtual void ModifyId(long new_id) {
      m_id = new_id;
   }
   virtual void ManageHistory() {
      Print("Default Manage History: unknown order");
      m_can_delete = true;
   }
   virtual void ManageHistory(CPositionDetails* pos) {
      Print("Default Manage History: closed order");
      m_can_delete = true;
   }
   virtual void Manage(CPositionDetails* pos) {
      //Print("managing pos id: ",pos.GetId());
   }
   virtual void Manage(CPendingOrderDetails* pos) {
      //Print("managing pos id: ",pos.GetId());
   }
};

class COrderTrackerFactory : public CObject {
public:
   virtual COrderTracker* Create(CPositionDetails* pos) {
      return NULL;
   }
   virtual COrderTracker* Create(CPendingOrderDetails* pos) {
      return NULL;
   }
};

class COrderTrackerFactoryDefault : public COrderTrackerFactory {
public:
   virtual COrderTracker* Create(CPositionDetails* pos) {
      return new COrderTrackerDefault(pos);
   }
   virtual COrderTracker* Create(CPendingOrderDetails* pos) {
      return new COrderTrackerDefault(pos);
   }
};

COrderTrackerFactoryDefault _order_tracker_factory_default;

COrderTrackerFactory* _order_tracker_factory = GetPointer(_order_tracker_factory_default);

class COrderManager : public CObject {
   CList orders;
private:
   bool GetPositionDetails(long id, CPositionDetails*& details) {
      CRequestGetPositionDetails req;
      req.position_id = id;
      ProcessOrder(ORDER_REQUEST_GET_POSITION_DETAILS,GetPointer(req));
      if (req.success) details = req.details;
      return req.success;
   }
    bool GetClosedPositionDetails(long id, CPositionDetails*& details) {
      CRequestGetPositionDetails req;
      req.position_id = id;
      req.include_closed = true;
      ProcessOrder(ORDER_REQUEST_GET_POSITION_DETAILS,GetPointer(req));
      if (req.success) details = req.details;
      return req.success;
   }
   bool GetOrderDetails(long id, CPendingOrderDetails*& details) {
      CRequestGetOrderDetails req;
      req.order_id = id;
      ProcessOrder(ORDER_REQUEST_GET_ORDER_DETAILS,GetPointer(req));
      if (req.success) details = req.details;
      return req.success;
   }
public:
   void Add(COrderTracker* order) {
      //Print("Adding order ",order.GetId());
      orders.Add(order);
   }
   void Manage() {
      if (orders.GetFirstNode() == NULL) return;
      CObject* node = orders.GetFirstNode();
      while (CheckPointer(node) != POINTER_INVALID) {
         if (InstanceOf<COrderTracker>(node)) {
            COrderTracker* order = node;
            CPositionDetails* pos;
            CPendingOrderDetails* orderdetails;
            if (this.GetOrderDetails(order.GetId(),orderdetails)) {
               order.Manage(orderdetails);
            } else if (this.GetPositionDetails(order.GetId(),pos)) {
               order.Manage(pos);
            } else if (this.GetClosedPositionDetails(order.GetId(),pos)) {
               //TODO: getting closed order details
               order.ManageHistory(pos);
            } else {
               order.ManageHistory();
            }
            if (order.CanDelete()) {
               node = orders.Next();
               orders.DeleteCurrent();
               if (node == NULL) break;
            } else {
               node = orders.GetNextNode();
            }
         } else {
            break;
         }
      }
   }
   

   COrderTracker* FindById(long id) {
      if (orders.GetFirstNode() == NULL) return NULL;
      CObject* node = orders.GetFirstNode();
      while (CheckPointer(node) != POINTER_INVALID) {
         if (InstanceOf<COrderTracker>(node)) {
            COrderTracker* order = node;
            if (order.GetId() == id) {
               return order;
            }
         } else {
            break;
         }
         node = node.Next();
      }
      return NULL;
   }
};

COrderManager _OrderTracker__DefaultManager;
COrderManager* _OrderTrackerManager = GetPointer(_OrderTracker__DefaultManager);

#ifdef __MQL4__
CPositionDetailsImpl __OrderTracker_Pos;
CPendingOrderDetailsImpl __OrderTracker_Order;
#endif

void OrderProcessorOrderTracker(int id, void* parameters, COrderProcessor* next) {
   if (id == ORDER_REQUEST_OPEN_MARKET) {
      Print("Tracking ",id);
   }
   if (CheckPointer(_order_tracker_factory) == POINTER_INVALID) {
      next.ProcessOrder(id,parameters);
      return;
   }
   switch(id) {
      case ORDER_REQUEST_OPEN_PENDING: {
         Print("Tracking open pending");
         next.ProcessOrder(id,parameters);
         if (InstanceOf<CRequestOpenPending>(parameters)) {
            CRequestOpenPending* req = parameters;
            #ifdef __MQL4__
            if (req.success && req.ticket >= 0 && OrderSelect(req.ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               _OrderTrackerManager.Add(_order_tracker_factory.Create(GetPointer(__OrderTracker_Order)));
            }
            #endif
         }
         break;
      }
      case ORDER_REQUEST_OPEN_MARKET: {
         Print("Tracking open market");
         next.ProcessOrder(id,parameters);
         if (InstanceOf<CRequestOpenMarket>(parameters)) {
            CRequestOpenMarket* req = parameters;
            #ifdef __MQL4__
            if (req.success && req.ticket >= 0 && OrderSelect(req.ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               _OrderTrackerManager.Add(_order_tracker_factory.Create(GetPointer(__OrderTracker_Pos)));
            }
            #endif
         }
         break;
      }
      case ORDER_REQUEST_CLOSE_POSITION: {
         next.ProcessOrder(id,parameters);
         if (InstanceOf<CRequestClosePosition>(parameters)) {
            CRequestClosePosition* req = parameters;
            if (req.success && req.new_position_id >= 0) {
               COrderTracker* track = _OrderTrackerManager.FindById(req.position_id);
               if (track != NULL) {
                  track.ModifyId(req.new_position_id);
               }
            }
         }
         break;
      }
      default:
         next.ProcessOrder(id,parameters);
   }
}
