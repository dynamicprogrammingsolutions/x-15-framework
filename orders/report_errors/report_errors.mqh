//+------------------------------------------------------------------+
#property strict

#include "../order_request_codes.mqh"
#include "../order_processor_register.mqh"
#include "../../objecttools.mqh"
#include "../market_orders/request_market_orders.mqh"
#include "../pending_orders/request_pending_orders.mqh"
#include "../modify_pending_order/request_modify_pending_order.mqh"
#include "../modify_position/request_modify_position.mqh"
#include "../close_position/request_close_position.mqh"
#include "../share/face_request_error.mqh"
#include "../share/errordescription.mqh"
#include "../../logger.mqh"

void OrderProcessorReportErrors(int request, void* parameters, COrderProcessor* next) {
   next.ProcessOrder(request,parameters);
   
   switch(request) {
      case ORDER_REQUEST_OPEN_MARKET:
      case ORDER_REQUEST_OPEN_PENDING:
      case ORDER_REQUEST_MODIFY_POSITION:
      case ORDER_REQUEST_MODIFY_PENDING:
      case ORDER_REQUEST_CLOSE_POSITION:
      {
         bool success = true;
         int error = 0;
         switch(request) {
            case ORDER_REQUEST_OPEN_MARKET: {
               CRequestOpenMarket* req = dynamic_cast<CRequestOpenMarket*>(request);
               if (req != NULL) {
                  success = req.success;
                  error = req.error;
               }
               break;
            }   
            case ORDER_REQUEST_OPEN_PENDING: {
               CRequestOpenPending* req = dynamic_cast<CRequestOpenPending*>(request);
               if (req != NULL) {
                  success = req.success;
                  error = req.error;
               }
               break;
            }
            case ORDER_REQUEST_MODIFY_POSITION: {
               CRequestModifyPosition* req = dynamic_cast<CRequestModifyPosition*>(request);
               if (req != NULL) {
                  success = req.success;
                  error = req.error;
               }
               break;
            }
            case ORDER_REQUEST_MODIFY_PENDING: {
               CRequestModifyPending* req = dynamic_cast<CRequestModifyPending*>(request);
               if (req != NULL) {
                  success = req.success;
                  error = req.error;
               }
               break;
            }
            case ORDER_REQUEST_CLOSE_POSITION:{
               CRequestClosePosition* req = dynamic_cast<CRequestClosePosition*>(request);
               if (req != NULL) {
                  success = req.success;
                  error = req.error;
               }
               break;
            }
         }
      
         if (!success) {
            print(("order error: ",ErrorDescription(error)," details: ",__GetRequestDetails(parameters)));
         }

      }
   }
   
}

string __GetRequestDetails(CRequest* request) {
   switch(request.Type()) {
      case ORDER_REQUEST_OPEN_MARKET: {
         CRequestOpenMarket* req = dynamic_cast<CRequestOpenMarket*>(request);
         if (req != NULL) {
            return StringConcatenate("Open Market price=",req.price," type=",EnumToString(req.order_type)," current_price=",req.current_price," sl=",req.sl," tp=",req.tp," volume=",req.volume);
         }
      }   
      case ORDER_REQUEST_OPEN_PENDING: {
         CRequestOpenPending* req = dynamic_cast<CRequestOpenPending*>(request);
         if (req != NULL) {
            return StringConcatenate("Open Pending price=",req.price," type=",EnumToString(req.order_type)," current_price=",req.current_price," sl=",req.sl," tp=",req.tp," volume=",req.volume);
         }
      }
      case ORDER_REQUEST_MODIFY_POSITION: {
         CRequestModifyPosition* req = dynamic_cast<CRequestModifyPosition*>(request);
         if (req != NULL) {
            return StringConcatenate("Modify Position id=",req.order_id," current_price=",req.current_price," sl=",req.sl," tp=",req.tp);
         }
      }
      case ORDER_REQUEST_MODIFY_PENDING: {
         CRequestModifyPending* req = dynamic_cast<CRequestModifyPending*>(request);
         if (req != NULL) {
            return StringConcatenate("Modify Pending id=",req.order_id," price=",req.price," current_price=",req.current_price," sl=",req.sl," tp=",req.tp);
         }
      }
      case ORDER_REQUEST_CLOSE_POSITION:{
         CRequestClosePosition* req = dynamic_cast<CRequestClosePosition*>(request);
         if (req != NULL) {
            return StringConcatenate("Close Position id=",req.position_id);
         }
      }
      default:
         return "Couldn't extract details from request";
   }
}