#include "..\order_request_codes.mqh"
#include "..\order_processor_register.mqh"
#include "..\..\objecttools.mqh"
#include "..\market_orders\request_market_orders.mqh"
#include "..\pending_orders\request_pending_orders.mqh"
#include "..\modify_pending_order\request_modify_pending_order.mqh"
#include "..\modify_position\request_modify_position.mqh"
#include "..\close_position\request_close_position.mqh"
#include "..\share\errordescription.mqh"
#include "..\..\logger.mqh"

int __reattempts = 10;
int __reattempt_sleep = 500;


void OrderFilterReattempts(int request, void* parameters, COrderProcessor* next) {
   int attempts = 0;
   while (true) {
      next.ProcessOrder(request,parameters);
      attempts++;
      bool success;
      int error;
      if (!__Reattempts_GetSuccessAndError(request,parameters,success,error)) break;
      if (success) break;
      string operation = __Reattempts_GetOperation(request,parameters);
      bool reattempt = false;
      bool sleep = false;
      switch(error) {
         case ERR_SERVER_BUSY:
         case ERR_NO_CONNECTION:
         case ERR_TOO_FREQUENT_REQUESTS:
         case ERR_MALFUNCTIONAL_TRADE:
         case ERR_BROKER_BUSY:
         case ERR_ORDER_LOCKED:
         case ERR_TOO_MANY_REQUESTS:
         case ERR_TRADE_CONTEXT_BUSY:
         case ERR_TRADE_TOO_MANY_ORDERS:
         case 9999:
            reattempt = true;
            sleep = true;
            break;
         case ERR_TRADE_TIMEOUT:
         case ERR_INVALID_PRICE:
         case ERR_INVALID_STOPS:
         case ERR_PRICE_CHANGED:
         case ERR_OFF_QUOTES:
         case ERR_REQUOTE:
         case 9998:
            reattempt = true;
            break;
      }
      if (!reattempt) {
         print(("Not attempting again ",operation," due to error ",error,": ",ErrorDescription(error)));
         break;
      }
      if (attempts > __reattempts) {
         print(("Reached max reattempt of ",operation," due to error ",error,": ",ErrorDescription(error)));
         break;
      }
      print(("Reattempt ",attempts,"/",__reattempts," ",sleep?"(with sleep) ":"",operation," due error: ",error,": ",ErrorDescription(error)));
      if (sleep) Sleep(__reattempt_sleep);
   
   }
}


string __Reattempts_GetOperation(int request, void* parameters) {
   switch(request) {
      //TODO: include as many details about the order as possible
      case ORDER_REQUEST_OPEN_MARKET: {
         CRequestOpenMarket* req = dynamic_cast<CRequestOpenMarket*>(parameters);
         if (req != NULL) {
            return StringConcatenate("Opening Market Order");
         }
         break;
      }   
      case ORDER_REQUEST_OPEN_PENDING: {
         CRequestOpenPending* req = dynamic_cast<CRequestOpenPending*>(parameters);
         if (req != NULL) {
            return StringConcatenate("Opening Pending Order");
         }
         break;
      }
      case ORDER_REQUEST_MODIFY_POSITION: {
         CRequestModifyPosition* req = dynamic_cast<CRequestModifyPosition*>(parameters);
         if (req != NULL) {
            return StringConcatenate("Opening Modify Position",req.order_id);
         }
         break;
      }
      case ORDER_REQUEST_MODIFY_PENDING: {
         CRequestModifyPending* req = dynamic_cast<CRequestModifyPending*>(parameters);
         if (req != NULL) {
            return StringConcatenate("Modify Pending Order",req.order_id);
         }
         break;
      }
      case ORDER_REQUEST_CLOSE_POSITION:{
         CRequestClosePosition* req = dynamic_cast<CRequestClosePosition*>(parameters);
         if (req != NULL) {
            return StringConcatenate("Closing Position id ",req.position_id);
         }
         break;
      }
   }
   return "Unknown Operation";
}

bool __Reattempts_GetSuccessAndError(int request, void* parameters, bool& success, int& error) {
   switch(request) {
      case ORDER_REQUEST_OPEN_MARKET: {
         CRequestOpenMarket* req = dynamic_cast<CRequestOpenMarket*>(parameters);
         if (req != NULL) {
            success = req.success;
            error = req.error;
         }
         break;
      }   
      case ORDER_REQUEST_OPEN_PENDING: {
         CRequestOpenPending* req = dynamic_cast<CRequestOpenPending*>(parameters);
         if (req != NULL) {
            success = req.success;
            error = req.error;
         }
         break;
      }
      case ORDER_REQUEST_MODIFY_POSITION: {
         CRequestModifyPosition* req = dynamic_cast<CRequestModifyPosition*>(parameters);
         if (req != NULL) {
            success = req.success;
            error = req.error;
         }
         break;
      }
      case ORDER_REQUEST_MODIFY_PENDING: {
         CRequestModifyPending* req = dynamic_cast<CRequestModifyPending*>(parameters);
         if (req != NULL) {
            success = req.success;
            error = req.error;
         }
         break;
      }
      case ORDER_REQUEST_CLOSE_POSITION:{
         CRequestClosePosition* req = dynamic_cast<CRequestClosePosition*>(parameters);
         if (req != NULL) {
            success = req.success;
            error = req.error;
         }
         break;
      }
   }
   return false;
}

/*
int CTrade::SleepIfBusy = 500;
int CTrade::SleepIfTooMuch = 2000;
int CTrade::SleepIfBrokerError = 0;
int CTrade::SleepIfPriceError = 0;

int CTrade::MaxRetryIfBusy = 19;
int CTrade::MaxRetryIfTooMuch = 4;
int CTrade::MaxRetryIfBrokerError = 2;
int CTrade::MaxRetryIfPriceError = 2;
int CTrade::MaxRetryIfMarketClosed = 0;
  
bool CTrade::CheckRetry(int errcode, ENUM_TRADE_ACTION action, int& retrycnt)
{
   //Print("checkretry "+retrycnt);
   int sleep = 0;
   int maxretry = 0;
   retrycnt++;
   switch (errcode) {
      // temporary problem (something is busy)
      case ERR_SERVER_BUSY:
      case ERR_NO_CONNECTION:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_BROKER_BUSY:
         sleep = CTrade::SleepIfBusy;
         maxretry = CTrade::MaxRetryIfBusy;
         break;
         
      case ERR_MARKET_CLOSED:
         sleep = CTrade::SleepIfBusy;
         maxretry = CTrade::MaxRetryIfMarketClosed;
         break;
         
      case ERR_TOO_FREQUENT_REQUESTS:
      case ERR_TOO_MANY_REQUESTS:
         sleep = CTrade::SleepIfTooMuch;
         maxretry = CTrade::MaxRetryIfTooMuch;
         break;
      
      case ERR_TRADE_TIMEOUT:
      case ERR_TRADE_MODIFY_DENIED:
         sleep = CTrade::SleepIfBrokerError;
         maxretry = CTrade::MaxRetryIfBrokerError;
         break;
      
      // retry with no sleep
      case ERR_INVALID_PRICE:
         switch (action) { case TRADE_ACTION_PENDING: case TRADE_ACTION_MODIFY: return(false); }
         
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_REQUOTE:
         sleep = CTrade::SleepIfPriceError;
         maxretry = CTrade::MaxRetryIfPriceError;
         break;

      default:
         return(false);
   }
   
   //Print(maxretry," ",retrycnt);
   if (maxretry >= retrycnt) {
      if (sleep > 0) Sleep(sleep);
      if (m_log_level>LOG_LEVEL_ERRORS) Print("Retrying (",retrycnt+1,"/",maxretry+1,")");
      return(true);
   } else return(false);
}

bool CTrade::OrderOpen(const string in_symbol, const int order_type, const double volume, const double price = 0, const double _sl = 0, const double _tp = 0, const datetime expiration = 0,const string _comment = "")
  {
//--- check stopped
   if(IsStopped(__FUNCTION__)) return(false);
   
   if(order_type==ORDER_TYPE_BUY && order_type==ORDER_TYPE_SELL)
   {
      if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",_comment,") Error: Invalid Order Type");
      return(false);
   }
   
   int retrycnt = 0;
   while (true) {
   
      m_ticket = -1;   
      int res;
      res = OrderSend(in_symbol,(int)order_type,volume,price,m_deviation,_sl,_tp,_comment,m_magic,expiration,getcolor(order_type));
      if (res >= 0)
      {   
         m_ticket = res;
         if(m_log_level>LOG_LEVEL_ERRORS) Print("Order Opened: (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),",",_comment,")");
         return(true);
      }
      else
      {
         int code = GetLastError();
         m_errcode = code;
         if(m_log_level>LOG_LEVEL_NO) Print("Order Open Failed (",in_symbol,",",COrderInfo::FormatType(order_type),",",volume,",",price,",",_sl,",",_tp,",",TimeToStr(expiration),",",_comment,") Error:", ErrorDescription(code), " (", code, ")");
         
         if (CheckRetry(m_errcode,TRADE_ACTION_PENDING,retrycnt)) continue;
         return(false);      
      }
  }
  return(false);
}
  

*/