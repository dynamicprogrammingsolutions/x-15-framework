#property strict

#define ORDER_FILTER_BUY_MARKET 0x0001
#define ORDER_FILTER_SELL_MARKET 0x0002
#define ORDER_FILTER_BUY_STOP 0x0004
#define ORDER_FILTER_SELL_STOP 0x0008
#define ORDER_FILTER_BUY_LIMIT 0x0010
#define ORDER_FILTER_SELL_LIMIT 0x0020
#define ORDER_FILTER_LONG 0x0015
#define ORDER_FILTER_SHORT 0x002A
#define ORDER_FILTER_MARKET 0x0003
#define ORDER_FILTER_PENDING 0x003C
#define ORDER_FILTER_STOP 0x000C
#define ORDER_FILTER_LIMIT 0x0030

bool FilterOrder(int order_type, int filters) {
   return
      ((bool)(filters & ORDER_FILTER_BUY_MARKET) && order_type==ORDER_TYPE_BUY) ||
      ((bool)(filters & ORDER_FILTER_SELL_MARKET) && order_type==ORDER_TYPE_SELL) ||
      ((bool)(filters & ORDER_FILTER_BUY_STOP) && order_type==ORDER_TYPE_BUY_STOP) ||
      ((bool)(filters & ORDER_FILTER_SELL_STOP) && order_type==ORDER_TYPE_SELL_STOP) ||
      ((bool)(filters & ORDER_FILTER_BUY_LIMIT) && order_type==ORDER_TYPE_BUY_LIMIT) ||
      ((bool)(filters & ORDER_FILTER_SELL_LIMIT) && order_type==ORDER_TYPE_SELL_LIMIT);
}
