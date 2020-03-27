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