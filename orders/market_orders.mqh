
#include "market_orders\market_orders.mqh"
#include "cnt_orders\cnt_orders.mqh"
#include "close_orders\close_orders.mqh"
#include "share\errordescription.mqh"
#include "select_positions\select_positions.mqh"
#include "modify_position\modify_position.mqh"

void RegisterMarketOrderProcessors() {
   RegisterOrderProcessor(OrderProcessorOpenMarket);
   RegisterOrderProcessor(OrderProcessorCloseOrders);
   RegisterOrderProcessor(OrderProcessorCntOrders);
   RegisterOrderProcessor(OrderProcessorSelectPositions);
   RegisterOrderProcessor(OrderProcessorModifyPosition);
}
