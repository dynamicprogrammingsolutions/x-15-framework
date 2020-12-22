
#include "pending_orders/pending_orders.mqh"
#include "cancel_orders/cancel_orders.mqh"
#include "select_orders/select_orders.mqh"
#include "modify_pending_order/modify_pending_order.mqh"
#include "cnt_orders/cnt_orders.mqh"
#include "cancel_order/cancel_order.mqh"
#include "get_position_details/get_position_details.mqh"
#include "get_triggered_pending_order/get_triggered_pending_order.mqh"
#include "share/errordescription.mqh"

void RegisterPendingOrderProcessors() {
   RegisterOrderProcessor(ORDER_REQUEST_OPEN_PENDING,OrderProcessorOpenPending);
   RegisterOrderProcessor(ORDER_REQUEST_MODIFY_PENDING,OrderProcessorModifyPending);
   RegisterOrderProcessor(ORDER_REQUEST_CANCEL_ALL,OrderProcessorCancelAll);
   RegisterOrderProcessor(ORDER_REQUEST_CANCEL_ORDER,OrderProcessorCancelOrder);

   RegisterOrderProcessor(ORDER_REQUEST_SELECT_ORDERS,OrderProcessorSelectOrders);
   RegisterOrderProcessor(ORDER_REQUEST_GET_POSITION_DETAILS,OrderProcessorGetPositionDetails);
   RegisterOrderProcessor(ORDER_REQUEST_GET_TRIGGERED_PENDING_ORDER,OrderProcessorGetTriggeredPendingOrder);   

}
