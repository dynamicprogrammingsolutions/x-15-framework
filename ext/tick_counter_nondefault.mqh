class CTickCounter {
public:
   CTickCounter(string symbol, ENUM_TIMEFRAMES tf):
      __symbol(symbol),
      __tf(tf),
      __tickcounter_tickcnt(0),
      __tickcounter_lastcandletime(0) {}
   string __symbol;
   ENUM_TIMEFRAMES __tf;
   int __tickcounter_tickcnt;
   datetime __tickcounter_lastcandletime;
};

void count_tick(CTickCounter* tick_counter) {
   if (Time[0] != tick_counter.__tickcounter_lastcandletime) {
      tick_counter.__tickcounter_lastcandletime = iTime(tick_counter.__symbol,tick_counter.__tf,0);
      tick_counter.__tickcounter_tickcnt = 0;
   }
   tick_counter.__tickcounter_tickcnt++;
}

bool isfirsttick(CTickCounter* tick_counter) {
   return tick_counter.__tickcounter_tickcnt == 1;
}
