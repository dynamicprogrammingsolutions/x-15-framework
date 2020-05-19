#property strict

#ifdef __MQL4__

#include "..\position_details.mqh"

class CPositionDetailsImpl : public CPositionDetails {
     CSymbolImpl m_symbol;
public:
     CPositionDetailsImpl(): m_symbol(NULL) {}
     virtual long GetId() {
         return OrderTicket();
     }
     virtual ENUM_ORDER_TYPE GetPositionType() {
         return OrderType();
     }
     virtual int GetMagic() {
         return OrderMagicNumber();
     }
     virtual datetime GetEntryTime() {
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