#include "priceround\processor_priceround.mqh"
#include "report_errors\report_errors.mqh"
#include "reattempts\reattempts.mqh"

void RegisterStandardOrderFilters() {

   #ifdef REGISTER_MONEY_MANAGEMENT_FILTER
      REGISTER_MONEY_MANAGEMENT_FILTER
   #endif

   RegisterOrderProcessor(OrderProcessorPriceRound);
   
   #ifdef REGISTER_STOPS_FILTER
      REGISTER_STOPS_FILTER
   #endif

   RegisterOrderProcessor(OrderFilterReattempts);
   
   RegisterOrderProcessor(OrderProcessorReportErrors);

}