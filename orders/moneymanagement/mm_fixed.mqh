#property strict

#include "moneymanagement.mqh"

class CMMFixed : public CMoneyManagement {
protected:
   double m_lots;
public:
   CMMFixed(double lots) : m_lots(lots) {}
   virtual double Calculate(CRequest* request) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(request);
      if (req != NULL) {
         return m_lots;
      } else {
         return 0;
      }
   }
   virtual double LastCalculatedLots() {
      return m_lots;
   }
};