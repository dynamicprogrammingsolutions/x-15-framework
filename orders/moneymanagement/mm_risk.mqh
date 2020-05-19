#property strict

#include "moneymanagement.mqh"
#include "..\share\account_info.mqh"
#include "..\share\request_order.mqh"
#include "..\..\logger.mqh"

class CMMRiskEquity : public CMoneyManagement {
protected:
   double m_lots;
   CAccountInfo* m_account_info;
   double m_risk;
   double m_default_lotsize;
public:
   CMMRiskEquity(double risk, double default_lotsize, CAccountInfo* account_info) :
      m_default_lotsize(default_lotsize),
      m_risk(risk),
      m_account_info(account_info)
   {}
   virtual double Calculate(CRequest* request) {
   
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(request);
      if (req != NULL) {
   
         double risk_money = m_account_info.GetEquity() * m_risk;
         double sl = req.sl;
         if (sl == 0) {
            print(("zero SL in SL based moneymanagement"));
            return m_default_lotsize;
         }
         CSymbol* _s = req.symbol;
         if (_s.TickValue() == 0) {
            print(("zero tickvalue in moneymanagement"));
            return m_default_lotsize;
         }
         return risk_money / ((sl/_s.TickSize()) * _s.TickValue());
      }
      return 0;
   }
};