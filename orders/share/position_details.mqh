#property strict

#include "..\symbols.mqh"

class CPositionDetails {
public:
    virtual long GetId() {
        return -1;
    }
    virtual ENUM_ORDER_TYPE GetPositionType() {
        return -1;
    }
    virtual int GetMagic() {
        return -1;
    }
    virtual double GetLotsize() {
        return -1;
    }
    virtual datetime GetEntryTime() {
        return 0;
    }
    virtual double GetEntryPrice() {
        return 0;
    }
    virtual double GetTakeprofit() {
        return -1;
    }
    virtual double GetStoploss() {
        return -1;
    }
    virtual double GetProfit() {
        return -1;
    }
    virtual double GetClosePrice() {
        return -1;
    }
    virtual string GetComment() {
        return NULL;
    }
    virtual string GetSymbol() {
        return NULL;
    }
    virtual CSymbol* GetCSymbol() {
        return NULL;
    }
};