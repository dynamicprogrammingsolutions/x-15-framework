#property strict

#include "stopcalc.mqh"
#include "../market_orders/request_market_orders.mqh"
#include "../pending_orders/request_pending_orders.mqh"
#include "../modify_pending_order/request_modify_pending_order.mqh"
#include "../modify_position/request_modify_position.mqh"

class CRequestOpenMarketWithStops : public CRequestOpenMarket {
public:
   CStop* slcalc;
   CStop* tpcalc;
};

class CRequestModifyPendingWithStops : public CRequestModifyPending {
public:
   CStop* slcalc;
   CStop* tpcalc;
   CStop* entrycalc;
};

class CRequestModifyPositionWithStops : public CRequestModifyPosition {
public:
   CStop* slcalc;
   CStop* tpcalc;
};

class CRequestOpenPendingWithStops : public CRequestOpenPending {
public:
   CStop* slcalc;
   CStop* tpcalc;
   CStop* entrycalc;
};
