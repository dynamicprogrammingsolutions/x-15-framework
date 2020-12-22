//+--------+----------------------------------------------------------+
//|                                                         time.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

datetime GivenSec(datetime from, int sec)
{
   int dist;
   dist = sec-TimeSec(from);
   return(from+dist);
}

datetime GivenMin(datetime from, int min)
{
   int dist;
   dist = min-TimeMin(from);
   return(from+dist*60);
}

datetime GivenHour(datetime from, int hour)
{
   int dist;
   dist = hour-TimeHour(from);
   return(from+dist*3600);
}

datetime GivenDayOfWeek(datetime from, int dow)
{
   int dist;
   dist = dow-TimeDayOfWeek(from);
   return(from+dist*86400);
}

datetime NextGivenSec(datetime from, int sec)
{
   int dist;
   dist = sec-TimeSec(from);
   if (dist < 0) dist+=60;
   return(from+dist);
}

datetime NextGivenMin(datetime from, int min)
{
   int dist;
   dist = min-TimeMin(from);
   if (dist < 0) dist+=60;
   return(from+dist*60);
}

datetime NextGivenHour(datetime from, int hour)
{
   int dist;
   dist = hour-TimeHour(from);
   if (dist < 0) dist+=24;
   return(from+dist*3600);
}

datetime NextGivenDayOfWeek(datetime from, int dow)
{
   int dist;
   dist = dow-TimeDayOfWeek(from);
   if (dist < 0) dist+=7;
   return(from+dist*86400);
}

datetime LastGivenSec(datetime from, int sec)
{
   int dist;
   dist = sec-TimeSec(from);
   if (dist > 0) dist-=60;
   return(from+dist);
}

datetime LastGivenMin(datetime from, int min)
{
   int dist;
   dist = min-TimeMin(from);
   if (dist > 0) dist-=60;
   return(from+dist*60);
}

datetime LastGivenHour(datetime from, int hour)
{
   int dist;
   dist = hour-TimeHour(from);
   if (dist > 0) dist-=24;
   return(from+dist*3600);
}

datetime LastGivenDayOfWeek(datetime from, int dow)
{
   int dist;
   dist = dow-TimeDayOfWeek(from);
   if (dist > 0) dist-=7;
   return(from+dist*86400);
}

datetime NextGivenTime(datetime from, int hour = 0, int min = 0, int sec = 0, int day_of_week = -1)
{
   if (sec >= 0) from = NextGivenSec(from,sec);
   if (min >= 0) from = NextGivenMin(from,min);
   if (hour >= 0) from = NextGivenHour(from,hour);
   if (day_of_week >= 0) from = NextGivenDayOfWeek(from,day_of_week);
   return(from);
}

datetime LastGivenTime(datetime from, int hour = 0, int min = 0, int sec = 0, int day_of_week = -1)
{
   if (sec >= 0) from = LastGivenSec(from,sec);
   if (min >= 0) from = LastGivenMin(from,min);
   if (hour >= 0) from = LastGivenHour(from,hour);
   if (day_of_week >= 0) from = LastGivenDayOfWeek(from,day_of_week);
   return(from);
}

datetime GivenTime(datetime from, int hour = 0, int min = 0, int sec = 0, int day_of_week = -1)
{
   if (sec >= 0) from = GivenSec(from,sec);
   if (min >= 0) from = GivenMin(from,min);
   if (hour >= 0) from = GivenHour(from,hour);
   if (day_of_week >= 0) from = GivenDayOfWeek(from,day_of_week);
   return(from);
}

datetime GivenTimeFrom(datetime from, int start_hour = 0, int start_min = 0, int start_sec = 0, int start_day_of_week = -1,  int hour = 0, int min = 0, int sec = 0, int day_of_week = -1)
{
   if (start_sec >= 0) from = LastGivenSec(from,start_sec);
   if (start_min >= 0) from = LastGivenMin(from,start_min);
   if (start_hour >= 0) from = LastGivenHour(from,start_hour);
   if (start_day_of_week >= 0) from = LastGivenDayOfWeek(from,start_day_of_week);
   if (sec >= 0) from = NextGivenSec(from,sec);
   if (min >= 0) from = NextGivenMin(from,min);
   if (hour >= 0) from = NextGivenHour(from,hour);
   if (day_of_week >= 0) from = NextGivenDayOfWeek(from,day_of_week);
   return(from);
}

bool AtTime(datetime& lasttime, int hour, int min = 0, int sec = 0, int dow = -1, int maxdelay = 1800)
{
   datetime time = TimeCurrent();
   if (lasttime == 0) {
      lasttime = time;
      return(false);
   }
   datetime at = NextGivenTime(lasttime+1,hour,min,sec,dow);      
   lasttime = time;
   return(time >= at && time-at < maxdelay);
}   

bool AtTimeGMT(datetime& lasttime, int hour, int min = 0, int sec = 0, int dow = -1, int maxdelay = 1800)
{
   datetime time = TimeGMT();
   if (lasttime == 0) {
      lasttime = time;
      return(false);
   }
   datetime at = NextGivenTime(lasttime+1,hour,min,sec,dow);      
   lasttime = time;
   return(time >= at && time-at < maxdelay);
}   


bool AtTime(datetime& lasttime, int hour, int min, int sec, int dow, int maxdelay, datetime& at)
{
   datetime time = TimeCurrent();
   if (lasttime == 0) {
      lasttime = time;
      return(false);
   }
   at = NextGivenTime(lasttime+1,hour,min,sec,dow);      
   lasttime = time;
   return(time >= at && time-at < maxdelay);
}   

bool AtTimeDt(datetime& lasttime, datetime at, int maxdelay = 1800)
{
   datetime time = TimeCurrent();
   if (lasttime == 0) {
      lasttime = time;
      return(false);
   }
   
   bool ret = time >= at && lasttime < at && time-at < maxdelay;
   lasttime = time;
   
   return(ret);
}   

#ifdef __MQL5__
int TimeHour(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.hour);
}

int TimeDayOfWeek(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.day_of_week);
}

int TimeDay(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.day);
}

int TimeYear(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.year);
}

int TimeMonth(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.mon);
}

#endif


int TimeSec(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.sec);
}

int TimeMin(datetime time)
{
   MqlDateTime _time;
   TimeToStruct(time,_time);
   return(_time.min);
}

int AutoGMTShift()
{
   return((int)MathRound((TimeGMT()-TimeCurrent())/3600.0));
}

int GetGMTShift(bool custom_gmt_shift = false, int gmtshift = 0)
{
   if (!custom_gmt_shift) gmtshift = AutoGMTShift();
   return(gmtshift);
}

datetime ConvertToGMT(datetime time, bool custom_gmt_shift = false, int gmtshift = 0)
{
   if (!custom_gmt_shift) gmtshift = AutoGMTShift();
   return time+gmtshift*3600;
}

datetime ConvertFromGMT(datetime time, bool custom_gmt_shift = false, int gmtshift = 0)
{
   if (!custom_gmt_shift) gmtshift = AutoGMTShift();
   return time-gmtshift*3600;
}

bool istradinghours(int _starthour, int _endhour, int _startminute=0, int _endminute=0, int startseconds=0, int endseconds=0, int shift = 0)
{
   datetime now = TimeCurrent()+shift*3600;
   datetime starttime = LastGivenTime(now,_starthour,_startminute,startseconds);
   datetime endtime = NextGivenTime(starttime+1,_endhour,_endminute,endseconds);
   return(now >= starttime && now <= endtime);
   return(true);
}

bool istradingdays(int _startday, int _endday, int _starthour = 0, int _endhour = 0, int _startminute=0, int _endminute=0, int startseconds=0, int endseconds=0, int shift = 0)
{
   datetime now = TimeCurrent()+shift*3600;
   datetime starttime = LastGivenTime(now,_starthour,_startminute,startseconds,_startday);
   datetime endtime = NextGivenTime(starttime+1,_endhour,_endminute,endseconds,_endday);
   return(now >= starttime && now <= endtime);
   return(true);
}