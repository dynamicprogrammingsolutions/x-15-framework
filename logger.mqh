//+------------------------------------------------------------------+
//|                                                       logger.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

/*
Help for replacement:
print\(([\ a-zA-Z()->\._",:]*\));

*/

#ifndef DISABLE_LOGGING
#define print(s1) Print s1
#endif

#ifdef DISABLE_LOGGING
#define print(s1)
#endif

#ifndef DISABLE_ALERTS
#define alert Alert
#endif

#ifdef DISABLE_ALERTS
#define alert
#endif

#ifdef ENABLE_DEBUG
#define debug(s1) Print s1
#endif

#ifndef ENABLE_DEBUG
#define debug(s1)

#endif

#ifdef FILTER_DEBUG

#ifdef ENABLE_DEBUG
#define debug(s1) { string __msg = StringConcatenate s1; if (FILTER_DEBUG(__msg)) { Print(__msg); } }
#endif

#endif

#ifdef FILTER_LOG

#ifndef DISABLE_LOGGING
#define print(s1) { string __msg = StringConcatenate s1; if (FILTER_LOG(__msg)) { Print(__msg); } }
#endif

#endif