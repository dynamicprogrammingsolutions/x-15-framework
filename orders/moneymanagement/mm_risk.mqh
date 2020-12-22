#property strict

#include "moneymanagement.mqh"
#include "../share/account_info.mqh"
#include "../share/request_order.mqh"
#include "../share/order_filters.mqh"
#include "../../logger.mqh"

CAccountInfoImpl __def_account_info;

class CMMRiskEquity : public CMoneyManagement {
protected:
   double m_lastlots;
   double m_lots;
   CAccountInfo* m_account_info;
   double m_risk;
   double m_default_lotsize;
   double m_maximum_lotsize;
public:
   CMMRiskEquity(double risk, double default_lotsize, CAccountInfo* account_info = NULL) :
      m_default_lotsize(default_lotsize),
      m_maximum_lotsize(0),
      m_risk(risk),
      m_account_info(account_info)
   {
      if (m_account_info == NULL) {
         m_account_info = GetPointer(__def_account_info);
      }
   }
   
   CMMRiskEquity(double risk, double default_lotsize, double maximum_lotsize, CAccountInfo* account_info) :
      m_default_lotsize(default_lotsize),
      m_maximum_lotsize(maximum_lotsize),
      m_risk(risk),
      m_account_info(account_info)
   {
      if (m_account_info == NULL) {
         m_account_info = GetPointer(__def_account_info);
      }
   }
   virtual double Calculate(CRequest* request) {
      if (m_maximum_lotsize > 0) {
         m_lastlots = MathMin(this.CalculateWithoutMaximum(request),m_maximum_lotsize);
      } else {
         m_lastlots = this.CalculateWithoutMaximum(request);
      }
      return m_lastlots;
   }
   virtual double CalculateWithoutMaximum(CRequest* request) {
      CRequestOrder* req = dynamic_cast<CRequestOrder*>(request);
      if (req != NULL) {
         double risk_money = m_account_info.GetEquity() * m_risk;
         //Print("risk money: ",m_risk);
         double sl = req.sl;
         if (sl == 0) {
            print(("zero SL in SL based moneymanagement"));
            return m_default_lotsize;
         }
         CSymbol* _s = req.symbol;
         double price = 0;
         if (FilterOrder(req.order_type,ORDER_FILTER_MARKET)) {
            price = GetPrice(_s,req.order_type);
         } else {
            price = req.price;
         }
         if (price == 0) {
            print(("couldn't determine price in moneymanagement"));
            return m_default_lotsize;
         }
         int sl_ticks = GetDiff(_s,STOP_MODE_SL,req.order_type,price,sl);
         //Print("Ticks: ",sl_ticks);
         //Print("Tick value: ",_s.TickValue());
         if (sl_ticks == 0) {
            print(("zero ticks in moneymanagement"));
            return m_default_lotsize;
         }
         if (_s.TickValue() == 0) {
            print(("zero tickvalue in moneymanagement"));
            return m_default_lotsize;
         }
         return risk_money / (sl_ticks * _s.TickValue());
      }
      return 0;
   }
   virtual double LastCalculatedLots() {
      return m_lastlots;
   }
};