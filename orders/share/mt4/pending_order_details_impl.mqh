#property strict

#ifdef __MQL4__

class CPendingOrderDetailsImpl : public CPendingOrderDetails {
public:
     virtual long GetId() {
         return OrderTicket();
     }
     virtual int GetOrderType() {
         return OrderType();
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
};

#endif