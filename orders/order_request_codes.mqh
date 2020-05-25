//+------------------------------------------------------------------+
//|                                          order_request_codes.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#define ORDER_REQUEST_OPEN_MARKET 1
#define ORDER_REQUEST_OPEN_PENDING 2
#define ORDER_REQUEST_MODIFY_MARKET 3
#define ORDER_REQUEST_MODIFY_POSITION 3
#define ORDER_REQUEST_MODIFY_PENDING 4
#define ORDER_REQUEST_CLOSE_POSITION 5

#define ORDER_REQUEST_CNT_ORDERS 20
#define ORDER_REQUEST_SELECT_ORDERS 21
#define ORDER_REQUEST_SELECT_POSITIONS 22
#define ORDER_REQUEST_GET_ORDER_DETAILS 23
#define ORDER_REQUEST_GET_TRIGGERED_PENDING_ORDER 24
#define ORDER_REQUEST_GET_POSITION_DETAILS 25

#define ORDER_REQUEST_CLOSE_MARKET 30
#define ORDER_REQUEST_CANCEL_PENDING 31
#define ORDER_REQUEST_CANCEL_ORDER 31
#define ORDER_REQUEST_CLOSE_ALL 32
#define ORDER_REQUEST_CANCEL_ALL 33
#define ORDER_REQUEST_PARTIAL_CLOSE 34

