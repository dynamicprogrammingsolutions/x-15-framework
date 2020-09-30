
#include "pending_orders\pending_orders.mqh"
#include "cancel_orders\cancel_orders.mqh"
#include "select_orders\select_orders.mqh"
#include "modify_pending_order\modify_pending_order.mqh"
#include "cnt_orders\cnt_orders.mqh"
#include "share\errordescription.mqh"

void RegisterPendingOrderProcessors() {
   RegisterOrderProcessor(OrderProcessorOpenPending);
   RegisterOrderProcessor(OrderProcessorCancelAll);
}