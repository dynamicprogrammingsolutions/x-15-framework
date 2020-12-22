
#include "market_orders/market_orders.mqh"
#include "cnt_orders/cnt_orders.mqh"
#include "close_orders/close_orders.mqh"
#include "share/errordescription.mqh"
#include "select_positions/select_positions.mqh"
#include "modify_position/modify_position.mqh"
#include "get_order_details/get_order_details.mqh"
#include "close_position/close_position.mqh"
#include "order_request_codes.mqh"

void RegisterMarketOrderProcessors() {
   RegisterOrderProcessor(ORDER_REQUEST_OPEN_MARKET, OrderProcessorOpenMarket);
   RegisterOrderProcessor(ORDER_REQUEST_CLOSE_ALL,OrderProcessorCloseOrders);
   RegisterOrderProcessor(ORDER_REQUEST_CNT_ORDERS,OrderProcessorCntOrders);
   RegisterOrderProcessor(ORDER_REQUEST_SELECT_POSITIONS,OrderProcessorSelectPositions);
   RegisterOrderProcessor(ORDER_REQUEST_MODIFY_POSITION,OrderProcessorModifyPosition);
   RegisterOrderProcessor(ORDER_REQUEST_GET_ORDER_DETAILS,OrderProcessorGetOrderDetails);
   RegisterOrderProcessor(ORDER_REQUEST_CLOSE_POSITION,OrderProcessorClosePosition);
}
