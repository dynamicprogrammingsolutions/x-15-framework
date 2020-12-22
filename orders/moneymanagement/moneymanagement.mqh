#property strict

#include "../order_request_base.mqh"

class CMoneyManagement {
public:
   virtual double Calculate(CRequest* request) {
      return 0;
   }
   virtual double LastCalculatedLots() {
      return 0;
   }
};
