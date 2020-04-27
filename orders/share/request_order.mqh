#property strict

#include "..\symbols.mqh"
#include "..\order_request_codes.mqh"
#include "..\order_request_base.mqh"
#include "..\moneymanagement\moneymanagement.mqh"

class CRequestOrder : public CRequest {
public:
   CSymbol* symbol;
   ENUM_ORDER_TYPE order_type;
   CMoneyManagement* mm;
   double volume;
   double current_price;
   double price;
   double sl;
   double tp;
   CRequestOrder():
      symbol(NULL),
      order_type(-1),
      volume(0),
      price(0),
      sl(0),
      tp(0)
   {}
};