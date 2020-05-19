#property strict

class CAccountInfo {
protected:
   CAccountInfo() {}
public:
   virtual double GetBalance() {
      return 0;
   }
   virtual double GetEquity() {
      return 0;
   }
};

class CAccountInfoImpl : public CAccountInfo {
public:
   virtual double GetBalance() {
      return AccountInfoDouble(ACCOUNT_BALANCE);
   }
   virtual double GetEquity() {
      return AccountInfoDouble(ACCOUNT_EQUITY);
   }
};