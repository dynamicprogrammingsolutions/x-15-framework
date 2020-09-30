#property strict

#ifdef __MQL4__

#include "../pending_order_details.mqh"

class CPendingOrderDetailsImpl : public CPendingOrderDetails {
   CSymbolImpl m_symbol;
public:
     CPendingOrderDetailsImpl(): m_symbol(NULL) {}
     virtual long GetId() {
         return OrderTicket();
     }
     virtual ENUM_ORDER_TYPE GetOrderType() {
         return (ENUM_ORDER_TYPE)OrderType();
     }
     virtual int GetMagic() {
         return OrderMagicNumber();
     }
     virtual datetime GetOrderTime() {
        return OrderOpenTime();
    }
     virtual double GetEntryPrice() {
         return OrderOpenPrice();
     }
     virtual double GetTakeprofit() {
         return OrderTakeProfit();
     }
     virtual double GetStoploss() {
         return OrderStopLoss();
     }
     virtual datetime GetExpiration() {
         return OrderExpiration();
     }
     virtual string GetComment() {
         return OrderComment();
     }
     virtual string GetSymbol() {
         return OrderSymbol();
     }
     virtual CSymbol* GetCSymbol() {
         m_symbol.SetSymbol(OrderSymbol());
         return GetPointer(m_symbol);
     }
};

#endif