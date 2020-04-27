//+------------------------------------------------------------------+
//|                                                       logger.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#ifndef DISABLE_LOGGING
#define print Print
#endif

#ifdef DISABLE_LOGGING
#define print()
#endif

#ifndef DISABLE_ALERTS
#define alert Alert
#endif

#ifdef DISABLE_ALERTS
#define alert
#endif

#ifdef ENABLE_DEBUG
#define debug Print
#define debugl(s1) Print s1
#endif

#ifndef ENABLE_DEBUG
#define debug()

#endif