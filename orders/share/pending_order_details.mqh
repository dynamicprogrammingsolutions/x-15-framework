#property strict


class CPendingOrderDetails {
public:
    virtual long GetId() {
        return -1;
    }
    virtual int GetOrderType() {
        return -1;
    }
    virtual int GetMagic() {
        return -1;
    }
    virtual datetime GetOrderTime() {
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
    virtual datetime GetExpiration() {
        return -1;
    }
    virtual string GetComment() {
        return NULL;
    }
    virtual string GetSymbol() {
        return NULL;
    }
};