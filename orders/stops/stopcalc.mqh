#property strict

#include "..\share\request_order.mqh"
#include "..\modify_pending_order\request_modify_pending_order.mqh"
#include "..\modify_position\request_modify_position.mqh"
#include "..\..\objecttools.mqh"

/* TODO: create a CStopRequest object, it will contain all the details required to calculate the stops */

class CStop {
public:
   virtual double Calculate(CRequest* request, ENUM_STOP_MODE stopmode) {
      return 0;
   }
   virtual bool Calculate(CRequest* request, ENUM_STOP_MODE stopmode, double& result) {
      result = Calculate(request,stopmode);
      return true;
   }
};

class CStopRequest {
public:
   CStopRequest(CRequestOrder* req, ENUM_STOP_MODE _stopmode): stopmode(_stopmode) {
      this.symbol = req.symbol;
      this.order_type = req.order_type;
      this.price = req.price;
      this.current_price = req.current_price;
   }
   CStopRequest(CRequestModifyPending* req, ENUM_STOP_MODE _stopmode): stopmode(_stopmode) {
      this.symbol = req.symbol;
      this.order_type = (ENUM_ORDER_TYPE)req.order_details.GetOrderType();
      this.price = req.order_details.GetEntryPrice();
      this.current_price = req.current_price;
      this.sl = req.order_details.GetStoploss();
      this.tp = req.order_details.GetTakeprofit();
   }
   CStopRequest(CRequestModifyPosition* req, ENUM_STOP_MODE _stopmode): stopmode(_stopmode) {
      this.symbol = req.symbol;
      this.order_type = (ENUM_ORDER_TYPE)req.position_details.GetPositionType();
      this.price = req.position_details.GetEntryPrice();
      this.current_price = req.current_price;
      this.sl = req.position_details.GetStoploss();
      this.tp = req.position_details.GetTakeprofit();
   }
   ENUM_STOP_MODE stopmode;
   CSymbol* symbol;
   ENUM_ORDER_TYPE order_type;
   double price;
   double current_price;
   double sl;
   double tp;
};

typedef double (*StopCalcFn_CRequestOrder)(CRequestOrder* req);

typedef bool (*StopCalcFn_CStopRequest)(CStopRequest* stopreq, CRequest* originalreq, double& result);

class CStopCalcFn_CRequestOrder : public CStop {
   StopCalcFn_CRequestOrder m_fn;
   ENUM_STOP_MODE m_stopmode;
public:
   CStopCalcFn_CRequestOrder(StopCalcFn_CRequestOrder fn, ENUM_STOP_MODE stopmode) : m_fn(fn), m_stopmode(stopmode) {}
   virtual double Calculate(CRequest* request, ENUM_STOP_MODE stopmode) {
      if (stopmode != m_stopmode) return -1;
      if (InstanceOf<CRequestOrder>(request)) {
         CRequestOrder* req_order = request;
         return m_fn(req_order);
      }
      return -1;
   }
};

class CStopCalcFn_CStopRequest : public CStop {
   StopCalcFn_CStopRequest m_fn;
   ENUM_STOP_MODE m_stopmode;
public:
   CStopCalcFn_CStopRequest(StopCalcFn_CStopRequest fn, ENUM_STOP_MODE stopmode) : m_fn(fn), m_stopmode(stopmode) {}
   virtual bool Calculate(CRequest* request, ENUM_STOP_MODE stopmode, double& result) {
      if (stopmode != m_stopmode) return false;
      if (InstanceOf<CRequestOrder>(request)) {
         CStopRequest stoprequest((CRequestOrder*)request,m_stopmode);
         return m_fn(GetPointer(stoprequest),request,result);
      } else if (InstanceOf<CRequestModifyPending>(request)) {
         CStopRequest stoprequest((CRequestModifyPending*)request,m_stopmode);
         stoprequest.stopmode = m_stopmode;
         return m_fn(GetPointer(stoprequest),request,result);
      } else if (InstanceOf<CRequestModifyPosition>(request)) {
         CStopRequest stoprequest((CRequestModifyPosition*)request,m_stopmode);
         stoprequest.stopmode = m_stopmode;
         return m_fn(GetPointer(stoprequest),request,result);
      }
      return false;
   }
};

CStop* GetStopCalc(StopCalcFn_CRequestOrder fn, ENUM_STOP_MODE stopmode) {
   return new CStopCalcFn_CRequestOrder(fn,stopmode);
}

CStop* GetStopCalc(StopCalcFn_CStopRequest fn, ENUM_STOP_MODE stopmode) {
   return new CStopCalcFn_CStopRequest(fn,stopmode);
}



