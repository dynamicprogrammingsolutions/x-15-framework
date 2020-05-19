#property strict

#define TRIAL_ONINIT
#define TRIAL_ONTICK

#ifdef TRIAL_PERIOD
   
   #ifndef TRIAL_EXPIRATION_TIME
   #define TRIAL_EXPIRATION_TIME __DATETIME__ + TRIAL_PERIOD * 86400
   #endif
   
   datetime __current_time_test = 0;
   datetime __get_current_time_test() {
      if (__current_time_test == 0) {
         FileDelete("tmp");
         int fh=FileOpen("tmp",FILE_WRITE);
         __current_time_test=(datetime)FileGetInteger(fh,FILE_CREATE_DATE);
         FileClose(fh);
         FileDelete("tmp");
      }
      return __current_time_test;
   }
   
   #define CURRENT_TIME (IsTesting()?__get_current_time_test():MathMin(TimeCurrent(),TimeLocal())) 
   #define TRIAL_EXPIRED (CURRENT_TIME >= TRIAL_EXPIRATION_TIME)
   #ifndef PAYMENT_LINK
      #define TRIAL_INSTRUCTIONS "send an email for instructions to support@metatraderprogrammer.com"
   #endif
   #ifdef PAYMENT_LINK
      #define TRIAL_INSTRUCTIONS StringConcatenate("send payment to ",PAYMENT_LINK," to get a full version,\nor send an email for a new version to support@metatraderprogrammer.com")
   #endif
   #define TRIAL_EXPIRED_MSG StringConcatenate("EA Expired on ",TimeToString(TRIAL_EXPIRATION_TIME,TIME_DATE|TIME_MINUTES),", current time: ",CURRENT_TIME,"\nPlease ",TRIAL_INSTRUCTIONS,"\n")
   #define TRIAL_NOT_EXPIRED_MSG StringConcatenate("EA will expire on ",TimeToString(TRIAL_EXPIRATION_TIME,TIME_DATE|TIME_MINUTES),", current time: ",CURRENT_TIME,"\nbefore that date, please ",TRIAL_INSTRUCTIONS,"\n")
   
   #define TRIAL_ONINIT if (TRIAL_EXPIRED) Alert(TRIAL_EXPIRED_MSG);
   #define TRIAL_ONTICK if (TRIAL_EXPIRED) { addcomment(TRIAL_EXPIRED_MSG); writecomment(); delcomment(); return;} else { addcomment(TRIAL_NOT_EXPIRED_MSG); }
   
#endif