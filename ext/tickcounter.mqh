
int __tickcounter_tickcnt = 0;
datetime __tickcounter_lastcandletime = 0;
void count_tick() {
   if (Time[0] != __tickcounter_lastcandletime) {
      __tickcounter_lastcandletime = Time[0];
      __tickcounter_tickcnt = 0;
   }
   __tickcounter_tickcnt++;
}

bool isfirsttick() {
   return __tickcounter_tickcnt == 1;
}
